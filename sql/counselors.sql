/* secondary students without assigned counsoler or elementary students*/

SELECT  distinct

[STU].[ID] AS [Student ID],

   [STU].[LN] AS [Last Name],

   [STU].[FN] AS [First Name],

   [LCN].[EM] AS [Counselor Email],

          [ENR].[SC] AS [School],

                        [STU].[GR] AS [Grade],

              CONVERT(VARCHAR(10),[ENR].[ED],101) AS [SC Enter Date],



            CONVERT(VARCHAR(10),[ENR].[LD],101) AS [SC Leave Date]





FROM [ENR]

INNER JOIN [STU] ON [STU].[ID] = [ENR].[ID] and [STU].[SC] = [ENR].[SC]

INNER JOIN [CNF] ON [STU].[ID] = [CNF].[PID]

LEFT JOIN [TCH] ON [TCH].[SC] = [STU].[SC] AND [TCH].[TN] = [STU].[CU] and [TCH].[SC] = [ENR].[SC]

LEFT JOIN [LCN] ON [LCN].[SC] = [ENR].[SC]

WHERE [ENR].[DEL] = 0

  AND [STU].[DEL] = 0

  AND [CNF].[DEL] = 0


  AND ( ( [ENR].[SC]  IN (1,2,3,5,6,7,8,10,11) and [STU].[CU] = 0 ) or [ENR].[SC] IN (9,12,13,16,18,19,20,21,23,24,25,26,27,28,30))



  AND LCN.CD = 5

AND [ENR].[ER] not IN (230, 240, 260, 280, 300, 370, 380, 400, 410, 440, 450, 470)

AND [CNF].[CD] = 'CI'

  AND DATEDIFF(day, [ENR].[ED], [ENR].[LD]) > 2

  and [ENR].[PR]  not in ('7','C')




UNION ALL

/* secondary students with assigned counsoler*/

SELECT  distinct

[STU].[ID] AS [Student ID],

   [STU].[LN] AS [Last Name],

   [STU].[FN] AS [First Name],

    [TCH].[EM] AS [Counselor Email],

          [ENR].[SC] AS [School],

                        [STU].[GR] AS [Grade],

              CONVERT(VARCHAR(10),[ENR].[ED],101) AS [SC Enter Date],



            CONVERT(VARCHAR(10),[ENR].[LD],101) AS [SC Leave Date]



FROM [ENR]

INNER JOIN [STU] ON [STU].[ID] = [ENR].[ID] and [STU].[SC] = [ENR].[SC]

INNER JOIN [CNF] ON [STU].[ID] = [CNF].[PID]

LEFT JOIN [TCH] ON [TCH].[SC] = [STU].[SC] AND [TCH].[TN] = [STU].[CU] and [TCH].[SC] = [ENR].[SC]

LEFT JOIN [LCN] ON [LCN].[SC] = [ENR].[SC]

WHERE [ENR].[DEL] = 0

  AND [STU].[DEL] = 0

  AND [CNF].[DEL] = 0



  AND ([STU].[CU] != 0 and [ENR].[SC]  IN (1,2,3,5,6,7,8,10,11)) -- Added condition

  AND LCN.CD = 5

AND [ENR].[ER] not IN (230, 240, 260, 280, 300, 370, 380, 400, 410, 440, 450, 470)

AND [CNF].[CD] = 'CI'

  AND DATEDIFF(day, [ENR].[ED], [ENR].[LD]) > 2   and [ENR].[PR]  not in ('7','C')

order by stu.id, enr.sc