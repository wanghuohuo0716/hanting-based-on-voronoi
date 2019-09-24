
clear all
close all
pursuers_num=4;
evaders_num=8;
agents_sum=pursuers_num+evaders_num;
t_step=0.01;
capture_dis=0.03;
counter=0;
L=1; %�߳�Ϊ1��������
square_x=[0 0 L L 0]; % 5�����������,��һ�������һ���غϲ����γɷ��ͼ��
square_y=[0 L L 0 0];
for i=1:agents_sum
    agents(i).pos=rand(1,2);
    agents(i).active=1; % evader ���flag
    agents(i).min_dis=100;
end
figure()
while 1
    if sum([agents(pursuers_num+1:agents_sum).active])==0 % ���е�evader����ץ����
        % �����Ƶ
        v = VideoWriter('wanghuohuo2.avi');
        v.FrameRate=4;
        open(v);
        writeVideo(v, F);
        close(v);
        return;     %�����е�evader��ץ�����˳�ѭ�����������򣬷������ִ��else
    else
        temp_pos=[];
        % ����active��agents��voronoiͼ
        index_active=[agents(:).active];
        index_active = find(index_active);
        temp_pos=[agents(index_active).pos];
        temp_pos=reshape(temp_pos,2,length(index_active))'; %��Ҫת����
        [vx,vy] = voronoi(temp_pos(:,1),temp_pos(:,2));%Ϊʲôvxvy�����У���
        [V,C] = voronoin(temp_pos);%V,C�ֱ����ʲô��
        
        % ��pursuer��evader��λ��
        plot(temp_pos(1:pursuers_num,1),temp_pos(1:pursuers_num,2),'go',...
             temp_pos(pursuers_num+1:length(index_active),1),temp_pos(pursuers_num+1:length(index_active),2),'r*',...
            vx,vy,'k-')
        
        % ��lable
        plabels = arrayfun(@(n) {sprintf('X%d', n)}, (index_active(:))');
        hold on
        Hpl = text(temp_pos(:,1), temp_pos(:,2), plabels, ...
              'HorizontalAlignment','left', ...
              'BackgroundColor', 'none');
        xlim([0 1]);
        ylim([0 1]);
        
        % �������������ڵ�Ԫ�����㣬����up�Ĺؼ���Ԥ�����������е�Ԫ������Ԫ��C����������Ķ��������Զ�Ķ���ID��ɾ������ֻ�������������ڵĶ���
        for i=1:length(C)
            out_index=[];
            inf_index=[];
            if sum(C{i}==1) % �ҵ�Ԫ��������Զ�ĵ������
                inf_index=find(C{i}==1);
            end
            for j=1:length(C{i}) % �ҵ�Ԫ������������ĵ������
                [in on]= inpolygon(V(C{i}(j),1),V(C{i}(j),2),square_x,square_y);
                if in==0 && on==0 % ���ⲿ
                    out_index=[out_index j];
                end
            end
            out_index=[inf_index out_index]; % �������Զ����ⲿ�������������һ������������Ⱥ�˳��ᵼ��ɾ����Ԫ��������Ŀ�����仯
            C{i}(out_index)=[]; % �������V�Ķ��㣬����C{i}�ж�����޷�����
        end
        
        %��vx��vy�е�����ҵ㣬�ڶ������һ�����յ㣬��һ�����һ������㣬����������߶��Ƿ��������ε��߶��н���
        cross_point=[];
        for i=1:length(vx)
            [xi,yi] = polyxpoly(vx(:,i),vy(:,i),square_x,square_y,'unique');
            cross_point=[cross_point;[xi yi]];
        end
        
        % �ѽ���������εĶ��㰴˳�򴢴浽V�У��������V�Ķ��㣬����C{i}�ж�����޷�������������ID
        old_V=V;
        V=[V;cross_point];
        
        % V������ӵĵ������������Ԫ������С�ڵ��ڣ�������ΪԪ������ID
        C_pos=temp_pos; % ����Ԫ����λ��
        for i=length(old_V)+1:length(V)
            V_dist=sum(abs(V(i,:)-C_pos).^2,2).^(1/2);
            V_index=find(V_dist==min(V_dist)); % ���������Ԫ��
            if length(V_index)==2
                C{V_index(1)}=[C{V_index(1)} i];
                C{V_index(2)}=[C{V_index(2)} i];
            else
                C{V_index}=[C{V_index} i]; % ���������뵽Ԫ���Ķ����б���
                V_dist(V_index)=max(V_dist); 
                V_index=find(V_dist==min(V_dist)); % �����ڶ�С��index��ʵ����������ͬ��
                C{V_index}=[C{V_index} i];
            end
        end
        
        % �������εĽǵ���뵽V�У���ӵ������Ԫ����һ�㶥��ֻ��һ��ռ�У��������Ҳ����������ռ��
        square=[square_x;square_y]';
        square(end,:)=[]; % ȥ���������ظ��Ľǵ�
        old_V=V;
        V=[V; square];
        for i=length(old_V)+1:length(V)
            V_dist=sum(abs(V(i,:)-C_pos).^2,2).^(1/2);
            V_index=find(V_dist==min(V_dist)); % ���������Ԫ��
            if length(V_index)==2
                C{V_index(1)}=[C{V_index(1)} i];
                C{V_index(2)}=[C{V_index(2)} i];
            else
                C{V_index}=[C{V_index} i]; % ���������뵽Ԫ���Ķ����б���
            end
        end
        
        % ����Ԫ����neighbor�����ģ�
        common_index=[];
        common_id=[];
        for i=1:length(C) % ������agents_sum��������������evaderҲ�����ȥ
            for j=1:length(C)
                if i~=j
                    temp_common=intersect(C{i},C{j});
                    if length(temp_common)==2
                        common_index=[common_index;temp_common];
                        common_id=[common_id;j];
                    end
                end
            end
            if length(common_id)~=0 % �������ĳ����common_idΪ�յ��³���������
                agents(i).neightbor.id=common_id;
                agents(i).neightbor.shared_boundary=common_index;
                agents(i).neightbor.mid_point= (V(common_index(:,1),:) + V(common_index(:,2),:))/2;  
                common_index=[]; %���
                common_id=[];
            end
        end
        for i=1:agents_sum
            agents(i).target=[];
        end
        
        % ���ݹ�ʽ����up
        for i=1:pursuers_num
            if sum(agents(i).neightbor.id>pursuers_num) % ���pursuer��Χ��evader�����е�
                near_id=find(agents(i).neightbor.id>pursuers_num); % ��neighbor��evader��id
                temp_err=agents(i).pos-agents(i).neightbor.mid_point(near_id,:);
                temp_dis=sum(abs(temp_err).^2,2).^(1/2);
                min_index = find(temp_dis==min(min(temp_dis))) + sum(agents(i).neightbor.id<=pursuers_num); % ����pursuer��ID,����Ҫ����Ϊtemp_dis��ȥ��ǰ��id
                agents(i).target=agents(i).neightbor.mid_point(min_index,:); % �ҵ������evader
                agents(i).up=(agents(i).target-agents(i).pos)/norm((agents(i).target-agents(i).pos));
            else % ���pursuer��Χû��evader�������evader�߹�ȥ
                for j=(pursuers_num+1):agents_sum
                    if agents(j).active
                        dis=norm(agents(i).pos - agents(j).pos);
                        if dis < agents(i).min_dis
                            agents(i).min_dis=dis; %����ÿ��evader�����е�pursuer����С����
                            agents(i).target=agents(j).pos;
                            agents(i).up=(agents(i).target-agents(i).pos)/norm((agents(i).target-agents(i).pos));
                        end
                    end
                end
            end
        end
        
        % ����Ue�����Ʋ�������ÿ��evader����Ԫ���������ƶ�
        % �ȱ���evader��Ԫ���������Ԫ��������λ��
%         cal=0;
%         for i=1:agents_sum
%             if agents(i).active
%                 cal=cal+1;
%             end
%         end
%         k1=5;
%         for i=pursuers_num+1:agents_sum
%             if agents(i).active
%                 xe=[];
%                 ye=[]; 
%                 for j=1:length(C{k1})
%                     xe=[xe V(C{k1}(j),1)];
%                     ye=[ye V(C{k1}(j),2)];
%                 end
%                 polyin = polyshape(xe,ye);
%                 [xc,yc]=centroid(polyin);
%                 agents(i).target=[xc,yc];
%                 agents(i).ue=(agents(i).target-agents(i).pos)/norm((agents(i).target-agents(i).pos));
%             end
%             k1=k1+1;
%             if k1>cal
%                 break;
%             end
%         end


        %����Ue�����Ʋ�������ÿ��evader����Ԫ���������ƶ�
        %˼·�ǣ���Ҫͨ��C������һ������evader����Ԫ�������ĵľ�����ȻC��ÿ����evader�����󶼻���£�
        %                      �䳤�Ȼ��̣��������Ǵ�C{5}��ʼ��ĩβ���Ǵ����evader������������ͨ��C
        %                      �ܹ��ܺõı��������д���evader��������
        %Ȼ���ٱ�������evader���ҵ����д��ģ���˳����ϵ��´�����������ȡ�������굱Ŀ��
        cen=[];%�����������ĵľ���
        for i=pursuers_num+1:length(C)
            xe=[];
            ye=[];
            for j=1:length(C{i})
                xe=[xe V(C{i}(j),1)];
                ye=[ye V(C{i}(j),2)];
            end
            polyin = polyshape(xe,ye);
            [xc,yc]=centroid(polyin);
            cen=[cen;[xc yc]];
        end
        k=1;
        for i=pursuers_num+1:agents_sum
            if agents(i).active 
                agents(i).target=cen(k,:);
                agents(i).ue=(agents(i).target-agents(i).pos)/norm((agents(i).target-agents(i).pos));
                k=k+1;
            end
        end
        
        %�����ƶ�·��
        for i=1:pursuers_num
            hold on
            plot([agents(i).pos(1,1);agents(i).target(1,1)], [agents(i).pos(1,2);agents(i).target(1,2)],'g-')
        end
        %ֻ����active��pursuersλ��
        for i=1:pursuers_num
            if agents(i).active
                agents(i).pos =agents(i).pos + t_step * agents(i).up;
            end
        end
        
        %ֻ����active��evader��λ��
        for i=pursuers_num+1:agents_sum
            if agents(i).active
                agents(i).pos = agents(i).pos + t_step * agents(i).ue;
            end
        end
        
        % �ж��Ƿ񴥷�������
        for i=(pursuers_num+1):agents_sum
            if agents(i).active
                for j=1:pursuers_num
                    dis=norm(agents(i).pos - agents(j).pos); 
                    if dis < agents(i).min_dis
                        agents(i).min_dis=dis; %����ÿ��evader�����е�pursuer����С����
                    end
                end
                % �ж�evader���ɹ�����Ĵ�������
                if agents(i).min_dis < capture_dis
                    agents(i).active=0;
                    for j=1:pursuers_num
                        agents(j).min_dis=100;% evader��������Ҫ������pursuer��min_dis���룬����ᳯ��������evader����ǰ��
                    end
                    hold on
                    plot(agents(i).pos(1,1),agents(i).pos(1,2),'g*')
                end
            end
        end
    end
    hold off
    counter=counter+1;
    F(counter) = getframe(gcf); %gcf��������ǰ����ı�����ֱ���þ��У�
    pause(0.01)
end
