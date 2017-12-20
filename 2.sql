USE [Reports]
GO

/****** Object:  UserDefinedFunction [dbo].[fnRetrieveHeadOfFamilyGroup]    Script Date: 18/12/2017 15:40:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[FnRetrieveHeadOfFamilyGroup] 
(	
	-- Add the parameters for the function here
	@CRMContactId bigint,
	@TenantId bigint
)

RETURNS TABLE

AS

	RETURN (SELECT TOP 1 CB.CRMContactId, CASE WHEN FirstName IS NULL AND LastName IS NULL THEN CorporateName 
				ELSE RTRIM(LTRIM(ISNULL(FirstName, '') + ' ' + ISNULL(LastName, ''))) END AS ClientName
			FROM CRM..TRelationship Rel
				JOIN Reports..VwClientBasic CB ON Rel.CRMContactToId = CB.CRMContactId  AND CB.IndigoClientId = @TenantId
				JOIN CRM..TRefRelationshipType RT ON Rel.RefRelTypeId = RT.RefRelationshipTypeId
				JOIN CRM..TRefRelationshipType RTC ON Rel.RefRelCorrespondTypeId = RTC.RefRelationshipTypeId
			WHERE Rel.IsFamilyFg = 1 AND ISNULL(RT.ArchiveFg, 0) = 0 
				AND	(Rel.CRMContactFromId = @CRMContactId or Rel.CRMContactToId = @CRMContactId) 
				AND CB.IsHeadOfFamilyGroup = 1
			ORDER BY CB.FamilyGroupCreationDate ASC	)
			
GO

---Test