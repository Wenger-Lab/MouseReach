function plot_all(total_leftp_exp, total_leftp_control, total_rightp_exp, total_rightp_control, pellets_leftp_exp, pellets_leftp_control, pellets_rightp_exp, pellets_rightp_control)

%manual data
manpel_leftp_exp = [85 65 67 61];
manpel_leftp_control = [89 95 90 94];
manpel_rightp_exp = [80 57 62 61];
manpel_rightp_control = [76 82 86 70];

%plot reaches left
subplot(2,2,1); hold on; %all reaches with the left paw
leg_exp_l = plot(total_leftp_exp,'r-'); leg_con_l = plot(total_leftp_control,'b-'); plot(total_leftp_exp,'ko'); plot(total_leftp_control,'ko'); ylabel('Reach count');

title('Left Paw'); names = {'4'; '7'; '14'; '21'}; set(gca,'xtick',(1:4),'xticklabel',names); xlabel('Days');
legend([leg_exp_l leg_con_l], 'Metamizol', 'Control')

%plot reaches right
subplot(2,2,2); hold on; %all reaches with the right paw
leg_exp_r = plot(total_rightp_exp,'r-'); leg_con_r = plot(total_rightp_control,'b-'); plot(total_rightp_exp,'ko'); plot(total_rightp_control,'ko'); ylabel('Reach count');

title('Right Paw'); names = {'4'; '7'; '14'; '21'}; set(gca,'xtick',(1:4),'xticklabel',names); xlabel('Days');
legend([leg_exp_r leg_con_r], 'Metamizol', 'Control')


%plot pellets left
subplot(2,2,3); hold on; 
p_leg_exp_l = plot(pellets_leftp_exp,'r--'); p_leg_con_l = plot(pellets_leftp_control, 'b--'); %experimental
plot(pellets_leftp_exp, 'ko'); plot(pellets_leftp_control, 'ko'); ylabel('Pellets grabbed');

plot(manpel_leftp_exp,'r-'); plot(manpel_leftp_control, 'b-'); %manual
plot(manpel_leftp_exp, 'ko'); plot(manpel_leftp_control, 'ko');

title('Left Paw'); names = {'4'; '7'; '14'; '21'}; set(gca,'xtick',(1:4),'xticklabel',names); xlabel('Days');
legend([p_leg_exp_l p_leg_con_l], 'Metamizol', 'Control')

%plot pellets right
subplot(2,2,4); hold on;
p_leg_exp_r = plot(pellets_rightp_exp, 'r--'); p_leg_con_r = plot(pellets_rightp_control, 'b--'); %experimental
plot(pellets_rightp_exp, 'ko'); plot(pellets_rightp_control, 'ko'); ylabel('Pellets grabbed');

plot(manpel_rightp_exp,'r-'); plot(manpel_rightp_control, 'b-'); %manual
plot(manpel_rightp_exp, 'ko'); plot(manpel_rightp_control, 'ko');

title('Right Paw'); names = {'4'; '7'; '14'; '21'}; set(gca,'xtick',(1:4),'xticklabel',names); xlabel('Days');
legend([p_leg_exp_r p_leg_con_r], 'Metamizol', 'Control')

end %end function
