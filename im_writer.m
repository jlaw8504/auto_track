function im_writer(path1,path2,im,name)
%test if im is double
if isa(im,'double') == 1
    error('Your image is in improper formate to be written');
end
for n = 1:length(path1(:,4))
    image= im(:,:,path1(n,4));
    imwrite(image,strcat(name,'_001','.tif'),'tif','Compression','lzw','WriteMode', 'append');
        image2= im(:,:,path2(n,4));
    imwrite(image2,strcat(name,'_002','.tif'),'tif','Compression','lzw','WriteMode', 'append');
end