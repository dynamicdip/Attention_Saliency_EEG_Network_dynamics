
%% About: This code plots figures presented in Fig 2 of Ghosh, Roy, Banerjee 2020

%% Workspace requirement: Variables 'rt_wt_static', 'rt_st_static' and 'rt_nt_static' containing reaction times of WT, ST and NT respectively in static tasks.
%% Workspace requirement: Variables 'rt_wt_dynamic', 'rt_st_dynamic' and 'rt_nt_dynamic' containing reaction times of WT, ST and NT respectively in dynamic tasks.
%% Output: Scatter plots and box-plots of Reaction Times (RTs) from static and dynamic stimulus

%Written by Priyanka Ghosh and Arpan Banerjee on 14.10.2020
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


load timeser&rt.mat rt_wt_static rt_st_static rt_nt_static rt_wt_dynamic rt_st_dynamic rt_nt_dynamic
%---------------------------------------------------------------
%Static task
figure; scatter(sort(rt_wt_static), 1:665, '+'); hold on;  scatter(sort(rt_st_static), 1:665, '+'); hold on;  scatter(sort(rt_nt_static), 1:665, '+');
title 'Distribution of reaction times across trials in static task'; xlabel 'Reaction Times (ms)'; ylabel 'Trials';
%% Box-plots for static stimulus' RT
box=rt_wt_static; box(2,:)=rt_st_static; box(3,:)=rt_nt_static;
figure; boxplot(box', 'Labels',{'WT','ST', 'NT'}); title 'Static task'; ylabel 'Reaction Times(ms)';

%-------------------------------------------------------------
% Dynamic task

figure; scatter(sort(rt_wt_dynamic), 1:665, '+'); hold on;  scatter(sort(rt_st_dynamic), 1:665, '+'); hold on;  scatter(sort(rt_nt_dynamic), 1:665, '+');
title 'Distribution of reaction times across trials in dynamic task'; xlabel 'Reaction Times (ms)'; ylabel 'Trials';
%% Box-plots for dynamic stimulus' RT
box=rt_wt_dynamic; box(2,:)=rt_st_dynamic; box(3,:)=rt_nt_dynamic;
figure; boxplot(box', 'Labels',{'WT','ST', 'NT'}); title 'Dynamic task'; ylabel 'Reaction Times(ms)';