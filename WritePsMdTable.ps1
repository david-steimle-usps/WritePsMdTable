function Write-PsMdTable {
  <#
  .SYNOPSIS

  .DESCRIPTION

  .EXAMPLE
  Write-PsMdTable -InputObject $MyObject -Columns @('Name','Year') -Justification @('L','C')

  .PARAMETER InputObject

  .PARAMETER Columns

  .PARAMETER Justification

  #>
  [CmdletBinding()]
  param(
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      HelpMessage = "The object for table creation."
    )]
    [psobject]$InputObject,
    [Parameter(
      Mandatory = $true,
      ValueFromPipeline = $true,
      HelpMessage = "The properties to use as column names."
    )]
    [array]$Columns,
    [Parameter(
      Mandatory = $false,
      ValueFromPipeline = $true,
      HelpMessage = "Array of L/C/R entries for Left/Center/Right justification of columns."
    )]
    [array]$Justification
  )

  $Table = New-Object "System.Collections.Generic.List[string]"

  $TableKey = New-Object "System.Collections.Generic.List[psobject]"

  $i = 0
  $Columns.ForEach({
    $TableKey.Add(
      [pscustomobject]@{
        Column = $PSItem
        Justification = $(
          if($Justification){
            if($Justification[$i]){
              $Justification[$i]
            } else {
              'C'
            }
          } else {
            'C'
          }
        )
      }
    )
    $i++
  })

  $Table.Add( "| $($TableKey.Column.ForEach({$PSItem+' |'}))" )
  $Table.Add( "| $($TableKey.Justification.ForEach({
    if($PSItem -eq 'L'){
      ':--- |'
    } elseif($PSItem -eq 'R'){
      '---: |'
    } else {
      ':--: |'
    }
  }))" )

  foreach($Item in $InputObject){
    $Row = $Item | Select-Object -Property $Columns
    $Values = $Row | Select-Object -Property $Columns | ForEach-Object { $PSItem.PSObject.Properties.Value }
    $Md = "| " + $($Values -join " | ") + " |"
    $Table.Add($Md)
  }

  $Table
}
