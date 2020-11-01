function coords2surf2(roi_coords1,roi_coords2,roi_coords3)

dd=gifti('Template.gii');

distanceThreshold = 4;


pqr = roi_coords1;
faces = dd.faces; vertices1 = repmat(dd.vertices,2,1);
vertices=vertices1(1:length(faces),:);
facecolor1 = repmat(dd.cdata, 2,1);
facecolor=facecolor1(1:length(faces),:);
facecolorx=facecolor;
facecolorxx=facecolor;
% colors1 =repmat(colormap(autumn),size(pqr,1),1);
colors1 =repmat([1 0 0],size(pqr,1),1);


for ii=1:size(pqr, 1)
    pos1 = find(abs(vertices(1:length(vertices),1) - pqr(ii, 1)) <= distanceThreshold & abs(vertices(1:length(vertices),2) - pqr(ii, 2)) <= distanceThreshold & abs(vertices(1:length(vertices),3) - pqr(ii, 3)) <= distanceThreshold  );
    facecolor(pos1,:) = repmat(colors1(ii,:), length(pos1), 1);
end

if (isempty(roi_coords2)~=1)
    xyz= roi_coords2;
    colors2 =repmat([0 1 0],size(xyz,1),1);
    
    for ii=1:size(xyz, 1)
        pos2 = find(abs(vertices(1:length(vertices),1) - xyz(ii, 1)) <= distanceThreshold & abs(vertices(1:length(vertices),2) - xyz(ii, 2)) <= distanceThreshold & abs(vertices(1:length(vertices),3) - xyz(ii, 3)) <= distanceThreshold  );
        facecolorx(pos2,:) = repmat(colors2(ii,:), length(pos2), 1);
    end
end;
hold on;

if (isempty(roi_coords3)~=1)
    abc= roi_coords3;
    colors3 =repmat([0 0 1],size(abc,1),1);
    
    for ii=1:size(abc, 1)
        pos3 = find(abs(vertices(1:length(vertices),1) - abc(ii, 1)) <= distanceThreshold & abs(vertices(1:length(vertices),2) - abc(ii, 2)) <= distanceThreshold & abs(vertices(1:length(vertices),3) - abc(ii, 3)) <= distanceThreshold  );
        facecolorxx(pos3,:) = repmat(colors3(ii,:), length(pos3), 1);
    end   
end;
% hold on;
% 
% 
% if (isempty(roi_coords4)~=1)
%     def= roi_coords4;
%     colors4 =repmat([0 0.75 0.75],size(def,1),1);
%     
%     for ii=1:size(def, 1)
%         pos4 = find(abs(vertices(1:length(vertices),1) - def(ii, 1)) <= distanceThreshold & abs(vertices(1:length(vertices),2) - def(ii, 2)) <= distanceThreshold & abs(vertices(1:length(vertices),3) - def(ii, 3)) <= distanceThreshold  );
%         facecolorxx(pos4,:) = repmat(colors4(ii,:), length(pos4), 1);
%     end
%     
% end;

count=1;
f=repmat([0 0 0],size(facecolor,1),1);
for i=1:size(facecolor)
    if facecolor(i,1)==1;
        f(i,1)=1;
    end
    if facecolorx(i,2)==1
        f(i,2)=1;
    end
     if facecolorxx(i,3)==1
         f(i,3)=1;
     end
   
end

for i=1:size(f,1)
    if f(i,:)==[0 0 0]
        f(i,:)=facecolor(i,:);
    end
    if f(i,:)==[1 1 1]
        f(i,:)=[0 0 0];
    end
    
%     if f(i,:)==[1 1 0]
%         count=count+1;
%     end
end


hold on;

p = patch('Faces',faces,'Vertices',vertices,'FaceVertexCData',f,...
    'FaceColor','flat','CDataMapping','direct','EdgeColor','none','facealpha',1);
set(p,'AmbientStrength',1.0,'DiffuseStrength',.0001); 

disp(count);

j=1;
for i=1:size(f,1)
    if f(i,:)==[1 1 0]
        B(j,:)=vertices(i,:);
        j=j+1;
    end
end


daspect([1 1 1])
% view(3);
% view([-58 8]);
axis tight
camlight
lighting phong
axis off;
shading interp;