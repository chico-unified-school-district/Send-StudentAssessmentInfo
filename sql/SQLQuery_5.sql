SELECT STU.ID AS [Student ID],
    STU.SC AS [School],
    COALESCE(CNF.CD, DSP.DS) AS [TA],
    STU.CU,
    COALESCE(TCH.EM, LCN.EM) AS [Email]
FROM
    (STU
    Left JOIN DSP ON STU.ID = DSP.PID AND DSP.DEL = 0 AND DSP.DS = 'TA'
    Left JOIN CNF ON STU.ID = CNF.PID AND CNF.DEL = 0 AND CNF.CD = 'TA')
    --Right JOIN DSP ON STU.ID = DSP.PID AND DSP.DEL = 0 AND DSP.DS = 'TA'
    LEFT JOIN TCH ON STU.SC = TCH.SC AND STU.CU = TCH.TN AND TCH.DEL = 0 AND STU.SC IN (1,2,3,5,6,7,8,9,10,11) --Secondary sites 
    LEFT JOIN LCN ON STU.SC = LCN.SC AND LCN.DEL = 0 AND LCN.CD = 5 AND STU.SC IN (12,13,16,18,19,20,21,23,24,25,26,27,28,30)
-- primary site
WHERE STU.DEL = 0 and COALESCE(CNF.CD, DSP.DS) IS NOT NULL
    and STU.TG = 'I'

-- TA = Threat assessment
-- CU = Teacher
-- K-5 CU is classroom teacher
-- 6-12 it's the counselor