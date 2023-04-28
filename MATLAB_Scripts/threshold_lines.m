function [diagonal, horizontal] = threshold_lines(csv, box)

%patch (delete later)
if isnan(nanmean(csv.x(strcmp(csv.bodyparts,'CornerUp') & csv.box == box & csv.likelihood > 0.9)))

cornerup = [nanmean(csv.x(strcmp(csv.bodyparts,'CornerSub') & csv.box == box & csv.likelihood > 0.9)),... %if no cornerup, substitute with CornerSub
nanmean(csv.y(strcmp(csv.bodyparts,'CornerSub') & csv.box == box & csv.likelihood > 0.9))];
cornerdown = [nanmean(csv.x(strcmp(csv.bodyparts,'CornerDown') & csv.box == box & csv.likelihood > 0.9)),...
nanmean(csv.y(strcmp(csv.bodyparts,'CornerDown') & csv.box == box & csv.likelihood > 0.9))];

else
%regular calculation [x y]
cornerup = [nanmean(csv.x(strcmp(csv.bodyparts,'CornerUp') & csv.box == box & csv.likelihood > 0.9)),...
nanmean(csv.y(strcmp(csv.bodyparts,'CornerUp') & csv.box == box & csv.likelihood > 0.9))];
cornerdown = [nanmean(csv.x(strcmp(csv.bodyparts,'CornerDown') & csv.box == box & csv.likelihood > 0.9)),...
nanmean(csv.y(strcmp(csv.bodyparts,'CornerDown') & csv.box == box & csv.likelihood > 0.9))];
end


d_linspace = abs(cornerdown(1,1)-cornerup(1,1)); %n points/pixels between cornerdown and cornerup
diagonal = [linspace(cornerup(1,1), cornerdown(1,1), d_linspace); linspace(cornerup(1,2), cornerdown(1,2), d_linspace)]'; %watch dimensions!

%horizontal threshold
horizontal = [linspace(cornerup(1,1), cornerdown(1,1), d_linspace); linspace(cornerup(1,2), cornerup(1,2), d_linspace)]';

end