#!/usr/bin/env python

# # ABOUT THIS FILE
# Steady-state, fixed-geometry version of the 1D subglacial canal script of
# Damsgaard et al. (2017), "Sediment behavior controls equilibrium width of
# subglacial channels", Journal of Glaciology 63, 1034-1048
# (Damsgaard2017paper_Fig12topPanel_1d-channel.py).
#
# Glacier and canal geometry are held fixed, so that the canal flowrate Q
# changes only through the upstream meltwater supply, m_dot. The water flux and
# canal effective pressure are found with the original flux_solver and
# pressure_solver. The canal effective pressure N_c at the withdrawal site
# (downstream end of the meltwater input) is reported for each flowrate, written
# to Nc_vs_Q.txt, and plotted as Fig. S8 (FigS8_canal_closure.pdf).
#
# Changes relative to the original script:
#   1. No time loop and no channel growth: S is fixed (SI section 3).
#   2. Bed slopes at alpha beneath an ice surface of equal slope (uniform
#      overburden), with alpha = 0.02383, the downstream slope of the canal case
#      in the glacier model; psi is computed from the ice-surface gradient
#      d(H+b)/ds, which reduces to the original psi expression when b = 0.
#   3. Canal width from Eq. (16) of Damsgaard et al. (2017),
#      W = sqrt(4 S / tan(theta)), instead of W = S/tan(theta).
#   4. Dirichlet condition N_c = 0 at the terminus.
#   5. Meltwater enters only along the upper half of the domain.
#   6. s_down and S are set so that N_c = 50 kPa at Q = 0.005 m^3/s and
#      N_c = 150 kPa when Q is halved.
#
# License: GNU Public License v3+ (see LICENSE.md)
# Original author: Anders Damsgaard, andersd@princeton.edu

import numpy


# # Model parameters
Ns = 49              # Number of nodes [-] (48 channel segments)
s_down = 785.04      # Canal length below the withdrawal site [m]
n_down = 23          # Number of segments below the withdrawal site [-]
Ls = (Ns - 1)*s_down/n_down  # Model length [m] (~1.64 km, ds ~ 34 m)
tol_Q = 1e-2         # Tolerance criteria for the norm. max. residual for Q
tol_P_c = 1e-2       # Tolerance criteria for the norm. max. residual for P_c
max_iter = 1e2*Ns    # Maximum number of solver iterations before failure

# Physical parameters
rho_w = 1000.        # Water density [kg/m^3]
rho_i = 910.         # Ice density [kg/m^3]
rho_s = 2600.        # Sediment density [kg/m^3]
g = 9.8              # Gravitational acceleration [m/s^2]
theta = 30.          # Angle of internal friction in sediment [deg]
D = 1.15e-3          # Mean grain size [m], Lajeuness et al 2010, series 1
tau_c = 0.016        # Critical Shields stress, Lajeunesse et al 2010, series 1
alpha = 0.02383      # Bed and ice-surface slope [-] (canal case in the glacier model)

# Boundary conditions
N_terminus = 0.      # Effective pressure at terminus [Pa]
Q_upstream = 1e-3    # Water influx upstream (must be larger than 0) [m^3/s]

# Channel hydraulic properties
manning = 0.1          # Manning roughness coefficient [m^{-1/3} s]
friction_factor = 0.1  # Darcy-Weisbach friction factor [-]

# Channel growth-limit parameters
c_1 = -0.118         # [m/kPa]
c_2 = 4.60           # [m]
N_inf = 4.           # Far-field effective pressure [kPa]

# Fixed canal cross-section [m^2]
S_fixed = 0.036435

# Canal flowrates at the withdrawal site [m^3/s]
Q_cases = {          # cases used in the glacier model (Fig. 2, Figs. S3, S5, S6, S9; Fig. 3)
    'baseline (N_c = 50 kPa)':        0.005,
    '21% reduction (N_c = 100 kPa)':  0.0039528,
    '50% reduction (N_c = 150 kPa)':  0.0025,
    'Fig. 3, dQ = 0.5 L/min':         0.005 - 0.5/6e4,
    'Fig. 3, dQ = 1 L/min':           0.005 - 1/6e4,
}
Q_site_list = numpy.sort(numpy.unique(numpy.concatenate(
    [numpy.round(numpy.linspace(0.001, 0.0053, 44), 7), list(Q_cases.values())])))


# # Initialize model arrays
# Node positions, terminus at Ls
s = numpy.linspace(0., Ls, Ns)
ds = s[1:] - s[:-1]

# Bed topography [m] and ice thickness [m]: equal slopes, uniform overburden
b = -alpha*s
H = 150.*numpy.ones_like(s)   # uniform; does not affect N_c (only its gradient enters psi)

# Initialize arrays for channel segments between nodes
S = numpy.ones(len(s) - 1)*S_fixed  # Cross-sect. area of channel segments [m^2]
W = numpy.sqrt(4.*S/numpy.tan(numpy.deg2rad(theta)))  # Eq. (16)
Q = numpy.zeros_like(S)      # Water flux in channel segments [m^3/s]
P_c = numpy.zeros_like(S)    # Effective pressure in channel segments [Pa]

# Meltwater input: linearly increasing profile of the original script, along
# the upper half of the domain only (segments 1 to Ns-1-n_down-1)
i_site = (Ns - 1) - n_down - 1  # Segment at the withdrawal site [-]
m_dot_shape = numpy.linspace(1e-6, 1e-5, Ns-1)
m_dot_shape[i_site+1:] = 0.


# # Helper functions
def gradient(arr, arr_x):
    # Central difference gradient of an array ``arr`` with node positions at
    # ``arr_x``.
    return (arr[1:] - arr[:-1])/(arr_x[1:] - arr_x[:-1])


def avg_midpoint(arr):
    # Averaged value of neighboring array elements
    return (arr[:-1] + arr[1:])/2.


def channel_hydraulic_roughness(manning, S, W, theta):
    # Determine hydraulic roughness assuming that the channel has no channel
    # floor wedge.
    l = W + W/numpy.cos(numpy.deg2rad(theta))  # wetted perimeter
    return manning**2.*(l**2./S)**(2./3.)


def channel_shear_stress(Q, S):
    # Determine mean wall shear stress from Darcy-Weisbach friction loss
    u_bar = Q/S
    return 1./8.*friction_factor*rho_w*u_bar**2.


def flux_solver(m_dot, ds):
    # Iteratively find new water fluxes
    it = 0
    max_res = 1e9  # arbitrary large value

    while max_res > tol_Q:

        Q_old = Q.copy()
        # dQ/ds = m_dot  ->  Q_out = m*delta(s) + Q_in
        # Upwind information propagation (upwind)
        Q[0] = Q_upstream
        Q[1:] = m_dot[1:]*ds[1:] + Q[:-1]
        max_res = numpy.max(numpy.abs((Q - Q_old)/(Q + 1e-16)))

        if it >= max_iter:
            raise Exception('Iterative solution not found for Q')
        it += 1

    return Q


def pressure_solver(psi, f, Q, S):
    # Iteratively find new effective pressures
    # dP_c/ds = f*rho_w*g*Q^2/S^{8/3} - psi  (Kingslake and Ng 2013)

    it = 0
    max_res = 1e9  # arbitrary large value
    while max_res > tol_P_c:

        P_c_old = P_c.copy()

        # Dirichlet BC (fixed effective pressure) at terminus
        P_c[-1] = N_terminus

        P_c[:-1] = P_c[1:] \
            + psi[:-1]*ds[:-1] \
            - f[:-1]*rho_w*g*Q[:-1]*numpy.abs(Q[:-1]) \
            / (S[:-1]**(8./3.))*ds[:-1]

        max_res = numpy.max(numpy.abs((P_c - P_c_old)/(P_c + 1e-16)))

        if it >= max_iter:
            raise Exception('Iterative solution not found for P_c')
        it += 1

    return P_c


def solve_Nc(Q_site):
    # canal effective pressure [kPa] and Shields/critical at the withdrawal site
    global Q, P_c
    m_dot = m_dot_shape*(Q_site - Q_upstream) \
        / numpy.sum(m_dot_shape[1:i_site+1]*ds[1:i_site+1])
    Q[:] = 0.;  P_c[:] = 0.           # start from zero, as in a fresh run
    Q = flux_solver(m_dot, ds)
    P_c = pressure_solver(psi, f, Q, S)
    shields = channel_shear_stress(Q, S)/((rho_s - rho_w)*g*D)
    return P_c[i_site]/1e3, shields[i_site]/tau_c


# Initialize remaining values
s_c = avg_midpoint(s)  # Channel section midpoint coordinates [m]

# Water-pressure gradient from geometry [Pa/m]
psi = -rho_i*g*gradient(H + b, s) - (rho_w - rho_i)*g*gradient(b, s)

f = channel_hydraulic_roughness(manning, S, W, theta)

# Closed form below the withdrawal site (uniform Q): N_c = A - c Q^2  [kPa]
s_dn = s_c[-1] - s_c[i_site]
A_kPa = psi[0]*s_dn/1e3
c_kPa = f[0]*rho_w*g*s_dn/S[0]**(8./3.)/1e3


# # Flowrate scenarios
lines = []
lines.append('S = {:.4f} m^2, W = {:.3f} m, L_max = {:.2f} m, psi = {:.1f} Pa/m'.format(
    S[0], W[0], c_1*N_inf + c_2, psi[0]))
lines.append('Withdrawal site, s_site = {:.1f} m; terminus, s_c[-1] = {:.1f} m; '
             's_down (site to terminus) = {:.1f} m'.format(s_c[i_site], s_c[-1], s_dn))
lines.append('Closed form: N_c = {:.1f} kPa - {:.3e} kPa s^2 m^-6 Q^2'.format(A_kPa, c_kPa))
lines.append('Q_site [m^3/s]\tN_c [kPa]\tShields/critical')
for Q_site in Q_site_list:
    Nc, sh = solve_Nc(Q_site)
    lines.append('{:.7f}\t{:.2f}\t\t{:.3f}'.format(Q_site, Nc, sh))
print('\n'.join(lines))
with open('Nc_vs_Q.txt', 'w') as fh:
    fh.write('\n'.join(lines) + '\n')


# # Fig. S8: canal effective pressure against flowrate at the withdrawal site
try:
    import matplotlib
    matplotlib.use('Agg')
    import matplotlib.pyplot as plt
except ImportError:
    print('matplotlib not available: Fig. S8 not written')
else:
    Qc = numpy.linspace(Q_upstream, 7e-3, 400)
    Qm = numpy.linspace(Q_upstream, 7e-3, 400)
    Nm = numpy.array([solve_Nc(q)[0] for q in Q_site_list])
    Q0 = Q_cases['baseline (N_c = 50 kPa)']
    fig, ax = plt.subplots(figsize=(5.2, 5.4))
    ax.plot(Qc, A_kPa - c_kPa*Qc**2, '-', color='#08519c', lw=2,
            label='1D canal model of Damsgaard et al. (2017), with\nfixed ice overburden and fixed canal geometry:\n'
                  r'$N_c = %.1f - %.2f\times10^{6}\,Q^2$' % (A_kPa, c_kPa/1e6))
    ax.plot(Qm, 50*(Qm/Q0)**(-2.5), '--', color='0.5', lw=1.2,
            label=r'Ng (2000): $N_c = 50\,(Q/%.3f)^{-5/2}$' % Q0)
    circ = ['baseline (N_c = 50 kPa)', '21% reduction (N_c = 100 kPa)', '50% reduction (N_c = 150 kPa)']
    sq = ['Fig. 3, dQ = 0.5 L/min', 'Fig. 3, dQ = 1 L/min']
    offs = [(10, 6), (10, 6), (-8, -16)]
    for k, key in enumerate(circ):
        q = Q_cases[key]; n = A_kPa - c_kPa*q**2
        ax.plot(q, n, 'o', mfc='white', mec='k', ms=7, zorder=3,
                label='Canal cases in Fig. 2 and figs. S3, S5, S6, S9' if k == 0 else None)
        ax.annotate('(%.3g, %.0f)' % (q, n), (q, n), textcoords='offset points', xytext=offs[k],
                    ha='left' if k < 2 else 'right', fontsize=8)
    for k, key in enumerate(sq):
        q = Q_cases[key]; n = A_kPa - c_kPa*q**2
        ax.plot(q, n, 's', color='#e34a33', ms=4, zorder=4, label='On-target canal cases in Fig. 3' if k == 0 else None)
    ax.annotate('Fig. 3: $N_c$ = %.2f, %.2f kPa' % tuple(A_kPa - c_kPa*Q_cases[k]**2 for k in sq),
                (Q_cases[sq[1]], A_kPa - c_kPa*Q_cases[sq[1]]**2), xytext=(2.0e-3, 25), fontsize=8, color='#e34a33',
                arrowprops=dict(arrowstyle='-', color='#e34a33', lw=0.8))
    ax.set_xlim(1e-3, 7e-3); ax.set_ylim(0, 300)
    fmt = matplotlib.ticker.ScalarFormatter(useMathText=True); fmt.set_powerlimits((-3, -3))
    ax.xaxis.set_major_formatter(fmt)
    ax.set_xlabel(r'Canal flowrate, $Q$ [m$^3$ s$^{-1}$]'); ax.set_ylabel(r'$N_c$ [kPa]')
    fig.subplots_adjust(left=0.14, right=0.96, bottom=0.11, top=0.74)
    fig.legend(*ax.get_legend_handles_labels(), loc='upper center', bbox_to_anchor=(0.55, 0.995), fontsize=8, frameon=False)
    fig.savefig('FigS8_canal_closure.pdf'); fig.savefig('FigS8_canal_closure.png', dpi=300)
    print('Fig. S8 written: FigS8_canal_closure.pdf / .png')
