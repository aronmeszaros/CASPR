% Base object for testing the IDObjective objects
%
% Author        : Darwin LAU
% Created       : 2016
% Description    :
classdef IDSolverTest < matlab.unittest.TestCase
    properties (ClassSetupParameter)
        model_config_type = struct('SCDM', TestModelConfigType.T_SCDM, ...
            'MCDM', TestModelConfigType.T_MCDM, ...
            'Active_passive_cables', TestModelConfigType.T_ACTIVE_PASSIVE_CABLES, ...
            'HCDM', TestModelConfigType.T_HCDM);
    end
    
    properties
        modelObj;
    end
    
    properties (TestParameter)
        qp_solver_type = struct('MATLAB', ID_QP_SolverType.MATLAB, ...
            'MATLAB_warm_start', ID_QP_SolverType.MATLAB_ACTIVE_SET_WARM_START, ...
            'OptiToolbox_IPOPT', ID_QP_SolverType.OPTITOOLBOX_IPOPT, ...
            'OptiToolbox_OOQP', ID_QP_SolverType.OPTITOOLBOX_OOQP);
        lp_solver_type = struct('MATLAB', ID_LP_SolverType.MATLAB, ...
            'OptiToolbox_OOQP', ID_LP_SolverType.OPTITOOLBOX_OOQP, ...
            'OptiToolbox_LP', ID_LP_SolverType.OPTITOOLBOX_LP_SOLVE);
        infp_solver_type = struct('MATLAB', ID_LP_SolverType.MATLAB, ...
            'OptiToolbox_OOQP', ID_LP_SolverType.OPTITOOLBOX_OOQP, ...
            'OptiToolbox_LP', ID_LP_SolverType.OPTITOOLBOX_LP_SOLVE);
    end
            
    methods (TestClassSetup)
        function setupModelObj(testCase, model_config_type)
            model_config = ModelConfig(model_config_type);
            testCase.modelObj = model_config.getModel(model_config.defaultCableSetId);
        end
    end
    
    methods (Test)
        function testQPSolver(testCase, qp_solver_type)
            id_objective = IDObjectiveMinQuadCableForce(ones(1, testCase.modelObj.numActuators));
            id_solver = IDSolverQuadProg(testCase.modelObj, id_objective, qp_solver_type);
            [actuation_soln, Q_opt, id_exit_type] = id_solver.resolveFunction(testCase.modelObj);
            testCase.assertIDSolverOutput(actuation_soln, Q_opt, id_exit_type);
        end
        
        function testLPSolver(testCase, lp_solver_type)
            id_objective = IDObjectiveMinLinCableForce(ones(testCase.modelObj.numActuators, 1));
            id_solver = IDSolverLinProg(testCase.modelObj, id_objective, lp_solver_type);
            [actuation_soln, Q_opt, id_exit_type] = id_solver.resolveFunction(testCase.modelObj);
            testCase.assertIDSolverOutput(actuation_soln, Q_opt, id_exit_type);
        end
        
        function testInfPSolver(testCase, infp_solver_type)
            id_objective = IDObjectiveMinInfCableForce(ones(testCase.modelObj.numActuators, 1));
            id_solver = IDSolverMinInfNorm(testCase.modelObj, id_objective, infp_solver_type);
            [actuation_soln, Q_opt, id_exit_type] = id_solver.resolveFunction(testCase.modelObj);
            testCase.assertIDSolverOutput(actuation_soln, Q_opt, id_exit_type);
        end
    end
    
    methods
        function assertIDSolverOutput(testCase, actuation_soln, Q_opt, id_exit_type)
            testCase.assertLength(actuation_soln, testCase.modelObj.numActuatorsActive, 'Cable forces output of wrong dimension');
            testCase.assertInstanceOf(Q_opt, 'double');
            testCase.assertInstanceOf(id_exit_type, 'IDSolverExitType');
        end
    end
end