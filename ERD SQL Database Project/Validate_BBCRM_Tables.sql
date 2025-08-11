SELECT a.*
FROM BBCRM_Address a
LEFT JOIN BBCRM_Constituent c ON a.Constituent_ID = c.BBCRM_ID
WHERE c.BBCRM_ID IS NULL;

SELECT i.*
FROM BBCRM_Interaction i
LEFT JOIN BBCRM_Constituent c ON i.Constituent_ID = c.BBCRM_ID
WHERE c.BBCRM_ID IS NULL;

SELECT a.*
FROM BBCRM_Address a
LEFT JOIN BBCRM_Address_Type t ON a.Address_Type_Code = t.ID
WHERE t.ID IS NULL;

SELECT i.*
FROM BBCRM_Interaction i
LEFT JOIN BBCRM_Interaction_Type t ON i.Interaction_Type_Code = t.ID
WHERE t.ID IS NULL;