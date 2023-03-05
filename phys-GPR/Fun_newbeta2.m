function beta_0 = Fun_newbeta2(X_input)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
n_input= size(X_input,2);
n_material=n_input-1;
%scan_rate=X_input(:,1);
%input_materials=X_input(:,2:n_input);

%X_2=x2fx(input_materials,'quadratic');

%X_basis=[scan_rate X_2];
n_beta_i=(n_material+1)*(n_material+2)/2;
beta_0=rand(n_beta_i+n_material+1,1)/100;

end

