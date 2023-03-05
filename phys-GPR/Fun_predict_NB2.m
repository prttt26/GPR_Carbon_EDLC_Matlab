function [target_predict, predict_Asd,  predict_rsd] = Fun_predict_NB2(gprMdl,input)
    if(isa(gprMdl,"classreg.learning.partition.RegressionPartitionedModel"))
        gprMdl_1=gprMdl.Trained{1};
    else
        gprMdl_1=gprMdl;
    end
    [target_predict_gpr, predict_sd, ~]=predict(gprMdl_1,input);
    target_predict=exp(target_predict_gpr+predict_sd.^2);
    predict_rsd=sqrt((exp(predict_sd.^2)-1).*exp(predict_sd.^2));
    predict_Asd=target_predict.*predict_rsd;
end