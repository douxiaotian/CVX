% Test full model

theta_init = [1, 0.1, -0.4, 0.6]';
theta_final = [-1, 0.3, -0.5, 0.7]';

%%%%%%%%%%%%%% PROBLEM PARAMETERS %%%%%%%%%%%%%%%%%
n = 4;           % # joint variables
T = 30;          % # time steps
ls = 3*T;        % # slack variables for position constraints (x,y,z) = 3 * T
lt = n*T;        % # theta variables total = #joints x #timesteps
lx = ls + 2*lt;  % # of variables for full problem

gamma = 0.1;     % regularization parameter on L1 norm of thetas

t_lim_max = [2.0857, 0.3142, 2.0857, 1.5446]';    % joint ranges max lim
t_lim_min = [-2.0857, -1.3265, -2.0857, 0.0349]'; % joint ranges min lim

theta_radius = 0.15; % initial radius of deviation
theta_linspace = getThetaLinspace(theta_init, theta_final, T); % size n x T
theta_min = vec(theta_linspace - theta_radius);
theta_max = vec(theta_linspace + theta_radius);

%%% VARIABLE NOTATION: %%%
%
% x = [s, theta, v]
% where theta = [t1(t=1), t2(t=1), t3(t=1), t4(t=1), t1(t=2), t2(t=2), t3(t=2), t4(t=2), t1(t=3), ..., t1(t=T), t2(t=T), t3(t=T), t4(t=T)]
%
% v follows a the same format. 
%
% s is similar, except it will be [..., x(t=ti), y(t=ti), z(t=ti), ...] as
% they are the position constraint slack variables. 
%
% Useful macros: sub-select [s, t, v] portions of x
get_s_from_x = @(x, ls, lt) (x(1:ls));
get_t_from_x = @(x, ls, lt) (x(ls+1:ls+lt));

% We have enough to construct the object and inequality constraints; test:
Zts = zeros(lt, ls);
Zst = zeros(ls, lt); 
Ztt = zeros(lt, lt);
It = eye(lt);
Is = eye(ls);

Gineq = ...
[Zts, It, -It;
 Zts, -It, -It;
 -Is, Zst, Zst;
 Zts, It, Ztt;
 Zts, -It, Ztt];

zt = zeros(lt, 1); zs = zeros(ls, 1);
hineq = [zt; zt; zs; theta_max; -theta_min];

is = ones(ls, 1); it = ones(lt, 1);
c_objective = [is; gamma*it; zt];

% Equalities: 
it1 = [ones(n,1); zeros(lt - n, 1)];
itT = [zeros(lt - n, 1); ones(n,1)];

Aeq = zeros(2*n, lx);
for i=1:n
    Aeq(i, ls+1 + (i-1)) = 1; % for t1(t=1), ..., tn(t=1)
end
for i=1:n % draw it out, do trial and error with indexing...
    Aeq(i+n, ls+1 + lt - n + i - 1) = 1; % for t1(t=T), ..., tn(t=T)
end

beq = [theta_init; theta_final];

cvx_begin
    variable x(lx)
    minimize (c_objective'*x)
    subject to 
        Gineq*x <= hineq
        Aeq*x == beq;
        %x(1:ls) == 0 % use this to test maximize
cvx_end

t_test = get_t_from_x(x,ls,lt);
figure; plot(t_test - vec(theta_linspace)); % should all be -theta_radius!! since we minimized.
% with equalities, will see first n and last n residuals be zero from the
% theta_linspace vec. 





