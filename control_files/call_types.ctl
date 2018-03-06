LOAD	DATA
INFILE	*
INTO	TABLE call_types
TRUNCATE
FIELDS	TERMINATED BY ';'
TRAILING NULLCOLS
	(
	call_type_id	INTEGER EXTERNAL,
	call_type_des
	)
BEGINDATA
-127;ECT_sUBOG
-126;ECT_sUBIC
-111;ECT_pbxOutgoingCall
-110;ECT_pbxIncomingCall
-102;ECT_pBX_SS_REG
-101;ECT_pBX_SS_ERAS
0;ECT_default1
1;ECT_moc
2;ECT_mtc
3;ECT_emergencyCall
6;ECT_mocOACSU
7;ECT_mtcOACSU
8;ECT_inCallModMoc
9;ECT_inCallModMtc
10;ECT_sSRegistration
11;ECT_sSErasure
12;ECT_sSActivation
13;ECT_sSDeactivation
14;ECT_sSInterrogation
15;ECT_sSUnstructuredProcessing
17;ECT_moMOBOX
18;ECT_mtMOBOX
19;ECT_moDPAD
26;ECT_roaming
27;ECT_transit
29;ECT_callForwarding
30;ECT_mtcSMS
31;ECT_mocSMS
32;ECT_emergencyCallTrace
33;ECT_sSInvocation
34;ECT_roaAttempt
43;ECT_tIR
44;ECT_voiceGroupServiceAMSC
45;ECT_tIRAttempt
46;ECT_voiceGroupServiceRMSC
59;ECT_processUnstructuredSsRequestMo
60;ECT_unstructuredSsRequestNi
61;ECT_unstructuredSsNotifyNi
65;ECT_mocAttempt
66;ECT_mtcAttempt
67;ECT_emergencyCallAttempt
93;ECT_callForwardingAttempt
900;ECT_EgressTransactionSMS
901;ECT_EgressMsgSMS
121;ECT_mtcMMS = 121,
122;ECT_mocMMS = 122,
123;ECT_mtcInterMMS = 123,
124;ECT_mocInterMMS = 124,
125;ECT_ussdCall = 125
