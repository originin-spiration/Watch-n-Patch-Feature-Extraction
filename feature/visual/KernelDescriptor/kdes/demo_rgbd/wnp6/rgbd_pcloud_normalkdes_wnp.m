
% written by Liefeng Bo on 03/27/2012 in University of Washington
% modified by Baoxiong Jia on 01/11/2018 in UCLA

clear;

% add paths
addpath('../../helpfun');
addpath('../../kdes');
addpath('../../emk');

% compute the paths of images
rt_dir = '/home/baoxiongjia/Projects/WNP-Preprocess/Dataset';
im_rt_dir = {'office', 'kitchen1', 'kitchen2'};
for idx = 1 : 3  
    im_dirs = dir_bo(fullfile(rt_dir, im_rt_dir{idx}));
    im_dirs = sort({im_dirs.name});
    if length(im_dirs) < 150
        end_idx = length(im_dirs);
    else
        end_idx = 150;
    end
    if length(im_dirs) < 126
        start_idx = length(im_dirs) + 1;
    else
        start_idx = 126;
    end
    for dir_idx = start_idx : end_idx
        data_path = fullfile(rt_dir, im_rt_dir{idx}, im_dirs{dir_idx});
        imsubdir = dir_bo(fullfile(data_path, 'depth'));
        impath = cell(1, length(1 : 3 : length(imsubdir)));
        file_idx = 1;
        for img_idx = 1 : 3 : length(imsubdir)
            impath{file_idx} = fullfile(data_path, 'depth', imsubdir(img_idx).name);
            file_idx = file_idx +  1;
        end
        
        savedir = fullfile(rt_dir, 'kdes', 'normal_depth', im_rt_dir{idx});

        % initialize the parameters of kdes
        kdes_params.grid = 8;   % kdes is extracted every 8 pixels
        kdes_params.patchsize = 40;  % patch size
        load('normalkdes_params');
        kdes_params.kdes = normalkdes_params;

        % initialize the parameters of data
        data_params.datapath = impath;
        data_params.tag = 1;
        data_params.minsize = 45;  % minimum size of image
        data_params.maxsize = 960; % maximum size of image
        data_params.savedir = ['../kdesfeatures/rgbd' 'normalkdes'];
        data_params.savedir = savedir;
        data_params.prefix = im_dirs{dir_idx};

        % extract kernel descriptors
        mkdir_bo(data_params.savedir);
        rgbdkdespath = get_kdes_path(data_params.savedir);
        
            gen_kdes_batch(data_params, kdes_params);
            rgbdkdespath = get_kdes_path(data_params.savedir);
    end
    %{
    featag = 1;
    if featag
        % learn visual words using K-means
        % initialize the parameters of basis vectors
        basis_params.samplenum = 10; % maximum sample number per image scale
        basis_params.wordnum = 1000; % number of visual words
        fea_params.feapath = rgbdkdespath;
        rgbdwords = visualwords(fea_params, basis_params);
        basis_params.basis = rgbdwords;

        % constrained kernel SVD coding
        disp('Extract image features ... ...');
            % initialize the params of emk
            emk_params.pyramid = [1 2 3];
            emk_params.ktype = 'rbf';
            emk_params.kparam = 0.001;
            fea_params.feapath = rgbdkdespath;
            rgbdfea = cksvd_emk_batch(fea_params, basis_params, emk_params);
            rgbdfea = single(rgbdfea);
            save -v7.3 rgbdfea_rgb_gradkdes rgbdfea;
        else
            load rgbdfea_rgb_gradkdes;
        end
        save -v7.3 rgb_words rgbdwords
    end
    %}
end

