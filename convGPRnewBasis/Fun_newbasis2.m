function X_basis = Fun_newbasis2(X_input)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
n_input= size(X_input,2);
n_material=n_input-1;
scan_rate=X_input(:,1);
input_materials=X_input(:,2:n_input);

%nuX=input_materials;
%for ii=1: size(X_input,1)
%    nuX(ii,:)=scan_rate(ii).*input_materials(ii,:);
%end
X_2=x2fx(input_materials,'quadratic');


X_basis=[scan_rate,repmat(scan_rate,1,size(input_materials,2)).*input_materials ,X_2];

end

