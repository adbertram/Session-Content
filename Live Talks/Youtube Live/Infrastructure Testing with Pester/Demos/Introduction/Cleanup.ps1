
<#
This can be implemented in the AfterAll block in the Pester describe block. This is the chance to perform any kind
of cleanup necessary. In our demo today we're going to cleanup any dependencies created but you could also revert
any changes made to an environment by the actual code you might be testing as well.

$removeactions here comes from our dependencies hashtable. We're keeping track of all the dependencies that are built
and then optionally removing them when we're done.
#>

foreach ($removeAction in $script:removeActions)
{
	Write-Host @whParams -Object 'Starting remove action...' -ForegroundColor Yellow
	& $removeAction
}