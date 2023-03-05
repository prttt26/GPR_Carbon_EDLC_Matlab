function [target_predict, predict_Asd,  predict_rsd] = Fun_predict(gprMdl,input)
    if(isa(gprMdl,"classreg.learning.partition.RegressionPartitionedModel"))
        gprMdl_1=gprMdl.Trained{1};
    else
        gprMdl_1=gprMdl;
    end
    [target_predict_gpr, predict_sd, ~]=predict(gprMdl_1,input);
    target_predict=target_predict_gpr;
    predict_rsd=predict_sd./target_predict_gpr;
    predict_Asd=predict_sd;
end