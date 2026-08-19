function Write-PsMdTable {
  <#
  .SYNOPSIS
  A tool for converting a PowerShell object into a markdown table.
  .DESCRIPTION
  Accepts object input, column names, and column justification to create a basic markdown table from the object. Column selection and justification preferences help build the table more accurately.

  Use `Get-Help Write-PsMdTable -Online` for further examples.
  .EXAMPLE
  $MyObject = @(
    [pscustomobject]@{
      Year = 4
      Name = 'J. Doe'
    },
    [pscustomobject]@{
      Year = 1
      Name = 'A. Newb'
    },[pscustomobject]@{
      Year = 2
      Name = 'C. Yalater'
    }
  )

  Write-PsMdTable -InputObject $MyObject -Columns @('Name','Year') -Justification @('L','C')

  .EXAMPLE
  $Splat = @{
    InputObject = (Get-Content .\data.json | ConvertFrom-Json) | Sort-Object -Property Year,Month,Day
    Columns = @('Release','Type','Artist','Album')
    Justification = @('C','C','R','L')
  }

  Write-PsMdTable @Splat

  .PARAMETER InputObject
  The object for table creation.

  .PARAMETER Columns
  The properties to use as column names in desired order.

  .PARAMETER Justification
  Array of L/C/R entries for Left/Center/Right justification of columns.

  .INPUTS
  PSObject

  .OUTPUTS
  String

  .LINK
  https://github.com/david-steimle-usps/WritePsMdTable
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
      HelpMessage = "The properties to use as column names in desired order."
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
