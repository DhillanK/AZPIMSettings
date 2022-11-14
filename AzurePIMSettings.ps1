<# 
Licensed under the MIT license.
Copyright (C) 2022 Dhillan Kalyan
Contributions made by Vlasta Pitro & Julian Fernandez


Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, 
publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

The following script returns the Azure AD Privileged Role Settings. It has been created to retrieve current settings and allow
you to change certain parameters with regards to the Admin Eligible Settings, Admin Member Settings and the User Member Settings.
#>

# Install and Import Modules #
Install-Module AzureAD
Install-Module AzureADPreview
Import-Module AzureAD
Import-Module AzureADPreview

# Azure Credentials Required #
$AzureAdCred = Get-Credential  
Connect-AzureAD -Credential $AzureAdCred

# Get Tenant ID Detail #

$Tenant = Get-AzureADTenantDetail
$TenantID = $Tenant.ObjectId
$TenantID

## Pre-requisite to create a CSV file is to run the commands below ##
# This gets the Display Name of the Roles and the RoleDefinitionID however it is labeled as Id. When Exported the Column Name should be renamed #
Get-AzureADMSRoleDefinition | ft displayname,id

# Get PIM Role Definition ID and ID - Both are required for setting#
Get-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Filter "ResourceID eq '$TenantID'" | ft RoleDefinitionId,Id

# You can you XLookup's with the data retrieved above to match the RoleDefinitionId with the Id to create the csv that is required below #

# Get PIM Role Settings. The Resource ID is the Tenant ID - Not Really required unless you have manually set a policy and want to check the settings applied#
#Get-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Filter "ResourceID eq '$TenantID'"

# The following portion of the script needs to be run per Role Definition ID before any settings are set #
$RoleDef = import-csv C:\Scripts\PIMRoles.csv -Delimiter ';'
foreach ($Role in $RoleDef) {
$Id = $Role.Id
$RoleDefID = $Role.RoleDefinitionId
Get-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Filter "ResourceID eq '$TenantID' and RoleDefinitionId eq '$RoleDefId'"
$settingaes = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRuleSetting
$settingaes.RuleIdentifier = "ExpirationRule"
$settingaes.Setting = '{"permanentAssignment":true,"maximumGrantPeriodInMinutes":525600}'
$settingaes2 = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRuleSetting
$settingaes2.RuleIdentifier = "AttributeConditionRule"
$settingaes2.Setting = '{"condition":null,"conditionVersion":null,"conditionDescription":null,"enableEnforcement":false}'
$settingaes3 = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRuleSetting
$settingaes3.RuleIdentifier = "MfaRule"
$settingaes3.Setting = '{"required":false}'
$settingams = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRuleSetting
$settingams.RuleIdentifier = "ExpirationRule"
$settingams.Setting = '{"permanentAssignment":true,"maximumGrantPeriodInMinutes":259200}'
$settingams2 = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRuleSetting
$settingams2.RuleIdentifier = "MfaRule"
$settingams2.Setting = '{"mfaRequired":true}'
$settingams3 = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRuleSetting
$settingams3.RuleIdentifier = "JustificationRule"
$settingams3.Setting = '{"required":true}'
$settingams4 = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRuleSetting
$settingams4.RuleIdentifier = "AttributeConditionRule"
$settingams4.Setting = '{"condition":null,"conditionVersion":null,"conditionDescription":null,"enableEnforcement":false}'
$settingums = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRuleSetting
$settingums.RuleIdentifier = "ExpirationRule"
$settingums.Setting = '{"permanentAssignment":true,"maximumGrantPeriodInMinutes":240}'
$settingums2 = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRuleSetting
$settingums2.RuleIdentifier = "MfaRule"
$settingums2.Setting = '{"mfaRequired":true}'
$settingums3 = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRuleSetting
$settingums3.RuleIdentifier = "JustificationRule"
$settingums3.Setting = '{"required":true}'
$settingums4 = New-Object Microsoft.Open.MSGraph.Model.AzureADMSPrivilegedRuleSetting
$settingums4.RuleIdentifier = "TicketingRule"
$settingums4.Setting = '{"ticketingRequired":false}'

Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -AdminEligibleSettings $settingaes3
Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -AdminEligibleSettings $settingaes
Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -AdminEligibleSettings $settingaes2
Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -AdminEligibleSettings $settingaes3
Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -AdminMemberSettings $settingams
Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -AdminMemberSettings $settingams2
Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -AdminMemberSettings $settingams3
Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -AdminMemberSettings $settingams4
Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -UserMemberSettings $settingums
Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -UserMemberSettings $settingums2
Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -UserMemberSettings $settingums3
Set-AzureADMSPrivilegedRoleSetting -ProviderId 'aadRoles' -Id $Id -ResourceId $TenantID -RoleDefinitionId $RoleDefID -UserMemberSettings $settingums4
}
