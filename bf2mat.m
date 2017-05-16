function stack = bf2mat(imdata)
%pre-allocate stack
stack = zeros([size(imdata{1,1}{1,1}),size(imdata,1)*size(imdata{1,1},1)]);
%loop through bf cell strucutre to get at images and put in 3D matrix
counter = 1;
for n = 1:size(imdata,1)
    for i = 1:size(imdata{n,1})
        stack(:,:,counter) = imdata{n,1}{i,1};
        counter = counter + 1;
    end
end
%determine class type and assign
test_im = imdata{1,1}{1,1};
S = whos('test_im');
class = S.class;
if strcmpi('uint16',class) == 1
    stack = uint16(stack);
elseif strcmpi('uint8',class) == 1
    stack = uint8(stack);
else
    error(strcat('Unknown class:',class));
end
end