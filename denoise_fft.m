function im_lowpass = denoise_fft(im_stk,scale)
%Function applies a low-pass filter using fft2. Larger scale values cause a
%smaller sampling of low-frequency information.
%Josh Lawrimore, 2017

%calculate the fft of stack, shift the high freq to center
im_fft = fftshift(fft2(im_stk));
%calc centers
centers = ceil(size(im_fft(:,:,1))/2);
%calcuate the maximum possbile radius of image
max_radius = min(size(im_fft(:,:,1)));
%% Create a circular mask at center of image
[x,y] = meshgrid(-(centers(2)-1):(size(im_fft,2)-centers(2)),...
    -(centers(1)-1):(size(im_fft,1)-centers(1)));
%Scale down radius
radius = max_radius/scale;
%create centered circle mask
c_mask=((x.^2+y.^2)<=radius^2);
%repmat to 3d
c_mask_3d = repmat(c_mask,1,1,size(im_fft,3));
%multiply im_fft by mask to create low pass filter
im_fft_lowpass = im_fft .* c_mask_3d;
%convert back to space
im_lowpass = real(ifft2(ifftshift(im_fft_lowpass)));
