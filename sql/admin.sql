/*TA code for counseling table*/
  SELECT distinct
    [STU].[ID],
    [STU].[LN],
    [STU].[FN],
    [LCN].[EM] AS [Email],
    [ENR].[SC] AS [School],
    [STU].[GR] AS [Grade],
    [ENR].[ED] AS [SC Enter Date],
    -- CONVERT(VARCHAR(10),[ENR].[ED],101) AS [SC Enter Date],
    [ENR].[LD] AS [SC Leave Date]
  -- CONVERT(VARCHAR(10),[ENR].[LD],101) AS [SC Leave Date]
  FROM [ENR]
    INNER JOIN [STU] ON [STU].[ID] = [ENR].[ID] and [STU].[SC] = [ENR].[SC]
    INNER JOIN [CNF] ON [STU].[ID] = [CNF].[PID]
    LEFT JOIN [TCH] ON [TCH].[SC] = [STU].[SC] AND [TCH].[TN] = [STU].[CU] and [TCH].[SC] = [ENR].[SC]
    LEFT JOIN [LCN] ON [LCN].[SC] = [ENR].[SC]
  WHERE [ENR].[DEL] = 0
    AND [STU].[DEL] = 0
    AND [CNF].[DEL] = 0
    AND LCN.CD = 1
    AND [ENR].[ER] not IN (230, 240, 260, 280, 300, 370, 380, 400, 410, 440, 450, 470)
    AND [CNF].[CD] ='TA'
    AND DATEDIFF(day, [ENR].[ED], [ENR].[LD]) > 2
    and [ENR].[PR]  not in ('7','C')
UNION ALL
  /* TA code assertive disciple-disposition */
  SELECT distinct
    [STU].[ID],
    [STU].[LN],
    [STU].[FN],
    [LCN].[EM] AS [Email],
    [ENR].[SC] AS [School],
    [STU].[GR] AS [Grade],
    [ENR].[ED] AS [SC Enter Date],
    -- CONVERT(VARCHAR(10),[ENR].[ED],101) AS [SC Enter Date],
    [ENR].[LD] AS [SC Leave Date]
  -- CONVERT(VARCHAR(10),[ENR].[LD],101) AS [SC Leave Date]
  FROM [ENR]
    INNER JOIN [STU] ON [STU].[ID] = [ENR].[ID] and [STU].[SC] = [ENR].[SC]
    INNER JOIN [DSP] ON [STU].[ID] = [DSP].[PID]
    LEFT JOIN [TCH] ON [TCH].[SC] = [STU].[SC] AND [TCH].[TN] = [STU].[CU] and [TCH].[SC] = [ENR].[SC]
    LEFT JOIN [LCN] ON [LCN].[SC] = [ENR].[SC]
  -- Added LCN join
  WHERE [ENR].[DEL] = 0 AND [STU].[DEL] = 0 AND [DSP].[DEL] = 0 AND LCN.CD = 1
    AND [ENR].[ER] not IN (230, 240, 260, 280, 300, 370, 380, 400, 410, 440, 450, 470)
    AND [DSP].[DS] = 'TA'
    AND DATEDIFF(day, [ENR].[ED], [ENR].[LD]) > 2 and [ENR].[PR]  not in ('7','C')
order by stu.id, enr.sc