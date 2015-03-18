clear

curr_vid=1;
[file,folder]=uigetfile('.mat');
load(fullfile(folder,file));
setappdata(0,'iscancel',false)
setappdata(0,'issave',false)

ptemp=p_med_bb;
for i=curr_vid:numel(moviefile)
    d1=sqrt(sum(diff(p_med_bb{i}(:,[1 3])).^2,2));
    d2=sqrt(sum(diff(p_med_bb{i}(:,[2 4])).^2,2));
    jframes=find(d1>20 | d2>20)';
    if true%~isempty(jframes)
        ptemp{i}=Labeler_fix(jframes,p_med_bb{i},moviefile{i});
    end
    if getappdata(0,'issave') || i==numel(moviefile)
        p_med_bb=ptemp;
        [save_file,save_folder]=uiputfile('.mat');
        curr_vid=i;
        save(fullfile(save_folder,save_file),'moviefile','p_med_bb','curr_vid')
    end
    if getappdata(0,'iscancel')
        curr_vid=1;
        break
    end
end
