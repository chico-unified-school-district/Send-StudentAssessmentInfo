SELECT [STU].[ID] AS [employeeId], [STU].[SC] AS [departmentNumber], [CNF].[CD] AS [TA], [TCH].[EM] AS [Email]
FROM
    (SELECT [CNF].*
    FROM [CNF]
    WHERE (DEL = 0 and [CNF].[CD] = 'TA')) [CNF]
    LEFT JOIN((SELECT [STU].*
    FROM STU
    WHERE DEL = 0 and STU.sc IN (1,2,3,5,6,7,8,10,11)) [STU]
    LEFT JOIN (SELECT [TCH].*
    FROM [TCH]
    WHERE DEL = 0) [TCH]
    ON [TCH].[SC] = [STU].[SC] AND [TCH].[TN] = [STU].[CU])
    ON [STU].[ID] = [CNF].[PID]
where STU.sc IN (1,2,3,5,6,7,8,10,11)
    and stu.tg = 'I';

SELECT [STU].[ID] AS [employeeId], [STU].[SC] AS [departmentNumber], [DSP].[DS] AS [TA], [TCH].[EM] AS [Email]
FROM
    (SELECT [DSP].*
    FROM [DSP]
    WHERE DEL = 0 and [DSP].[DS] = 'TA') [DSP]
    LEFT JOIN((SELECT [STU].*
    FROM STU
    WHERE DEL = 0 and STU.sc IN (1,2,3,5,6,7,8,10,11)) [STU]
    LEFT JOIN (SELECT [TCH].*
    FROM [TCH]
    WHERE DEL = 0) [TCH]
    ON [TCH].[SC] = [STU].[SC] AND [TCH].[TN] = [STU].[CU])
    ON stu.id = DSP.pid
where STU.sc IN (1,2,3,5,6,7,8,10,11)
    and stu.tg = 'I';

SELECT [STU].[ID] AS [employeeId], [STU].[SC] AS [departmentNumber], [CNF].[CD] AS [TA], [LCN].[EM] AS [Email]
FROM
    (SELECT [CNF].*
    FROM [CNF]
    WHERE (DEL = 0 and [CNF].[CD] = 'TA')) [CNF]
    LEFT JOIN((SELECT [STU].*
    FROM STU
    WHERE DEL = 0 and stu.sc in (9,12,13,16,18,19,20,21,23,24,25,26,27,28, 30)) [STU]
    LEFT JOIN (SELECT [LCN].*
    FROM [LCN]
    WHERE DEL = 0 and LCN.CD = 5) [LCN]
    ON [LCN].[SC] = [STU].[SC] ) ON [STU].[ID] = [CNF].[PID]
where stu.sc in (9,12,13,16,18,19,20,21,23,24,25,26,27,28, 30)
    and stu.tg = 'I';

SELECT [STU].[ID] AS [employeeId], [STU].[SC] AS [departmentNumber], [DSP].[DS] AS [TA], [LCN].[EM] AS [Email]
FROM
    (SELECT [DSP].*
    FROM [DSP]
    WHERE DEL = 0 and [DSP].[DS] = 'TA') [DSP]
    LEFT JOIN((SELECT [STU].*
    FROM STU
    WHERE DEL = 0 and stu.sc in (9,12,13,16,18,19,20,21,23,24,25,26,27,28, 30)) [STU]
    LEFT JOIN (SELECT [LCN].*
    FROM [LCN]
    WHERE DEL = 0 and LCN.CD = 5) [LCN]
    ON [LCN].[SC] = [STU].[SC] )
    ON stu.id = DSP.pid
where stu.sc in (9,12,13,16,18,19,20,21,23,24,25,26,27,28, 30)
    and stu.tg = 'I';