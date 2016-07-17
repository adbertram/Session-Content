<#
	===========================================================================
	Organization:	Genomic Health, Inc.
	Filename:		GHI.DSC.NetworkAdapter.psd1
	-------------------------------------------------------------------------
	Module Manifest
	-------------------------------------------------------------------------
	Module Name:	GHI.DSC.NetworkAdapter
	===========================================================================
#>

@{
	RootModule = 'GHI.DSC.NetworkAdapter.psm1'
	ModuleVersion = '<ModuleVersion>'
	GUID = '85e45ebe-78d2-4017-95a9-513aee2c573a'
	Author = 'Genomic Health, Inc.'
	CompanyName = 'Genomic Health, Inc.'
	Copyright = '© Genomic Health, Inc. All rights reserved.'
	PowerShellVersion = '5.0'
	RequiredModules = @('GHI.Library.Utility')
	RequiredAssemblies = @()
	FunctionsToExport = @('*')
	DscResourcesToExport = @('*')
	FileList = @()
	PrivateData = @{
		PSData = @{
			Category = 'DSC'
			Tags = @('PowerShell', 'EO')
			BranchName = '<BranchName>'
			IconUri = ''
			ProjectUri = ''
			LicenseUri = ''
			ReleaseNotes = ''
			RequireLicenseAcceptance = ''
			IsPrerelease = '<IsPrerelease>'
		}
	}
}
