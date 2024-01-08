Attribute VB_Name = "Module1"
'Create a script that loops through all the stocks for one year and outputs
'the following information:

'The ticker symbol

'Yearly change from the opening price at the beginning of a given year to the
'closing price at the end of that year.

'The percentage change from the opening price at the beginning of a given year
'to the closing price at the end of that year.

Sub Stock_compile():

For Each ws In Worksheets:

total_volume = 0
stock_counter = 1

'Track initial opening value of initial stock
init_open = ws.Cells(2, 3).Value

'Create column headers
ws.Cells(1, 12).Value = "Total stock volume"
ws.Cells(1, 12).Columns.AutoFit

ws.Cells(1, 11).Value = "Percent Change"
ws.Cells(1, 11).Columns.AutoFit

ws.Cells(1, 10).Value = "Yearly Change"
ws.Cells(1, 10).Columns.AutoFit

ws.Cells(1, 9).Value = "Ticker"
'ws.Cells(1, 9).Columns.AutoFit

'For i = 2 To 1000:
'For i = 2 To 22771:
For i = 2 To ws.Cells(Rows.Count, 1).End(xlUp).Row:
    'If ticker symbol changes
    If ws.Cells(i + 1, 1).Value <> ws.Cells(i, 1).Value Then
        total_volume = total_volume + Cells(i, 7)
        
        'Write Ticker symbol
        ws.Cells(stock_counter + 1, 9).Value = ws.Cells(i, 1).Value
        
        'Write total volume
        ws.Cells(stock_counter + 1, 12).Value = total_volume
        
        total_volume = 0
        
        stock_counter = stock_counter + 1
        
        'calculate yearly change and pct change
        end_value = ws.Cells(i, 6).Value
    
        yearly_change = end_value - init_open
        'MsgBox ("Yearly change: " + Str(yearly_change))
        ws.Cells(stock_counter, 10).Value = yearly_change
        
        'color yearly_change correctly
        If yearly_change > 0 Then
            ws.Cells(stock_counter, 10).Interior.ColorIndex = 4
        Else
            ws.Cells(stock_counter, 10).Interior.ColorIndex = 3
        End If
        
        
        'populate percent change column
        pct_change = (end_value - init_open) / init_open
        
        ws.Cells(stock_counter, 11).Value = FormatPercent(pct_change)
        
        
        
        init_open = ws.Cells(i + 1, 3).Value
    
    'if ticker symbol doesnt change
    Else
        total_volume = total_volume + ws.Cells(i, 7).Value
    
    End If

Next i

'Second Loop to register largest increase/decrease and biggest volume

'column 9 is ticker column
'lastrow_of_newlist=Cells(Rows.count, 9).End(xlUp).Row

'for j in 2 to lastrow_of_newlist

' initial values =

end_row_2 = ws.Cells(Rows.Count, 9).End(xlUp).Row
'value successfully 91


initial_ticker = ws.Cells(2, 9).Value
initial_ticker_increase = ws.Cells(2, 9).Value
initial_ticker_decrease = ws.Cells(2, 9).Value
initial_ticker_volume = ws.Cells(2, 9).Value

initial_pct_increase = ws.Cells(2, 11).Value
initial_pct_decrease = ws.Cells(2, 11).Value
initial_volume = ws.Cells(2, 12).Value

For j = 2 To end_row_2:
    If ws.Cells(j, 11).Value > initial_pct_increase Then
        initial_ticker_increase = ws.Cells(j, 9).Value
        initial_pct_increase = ws.Cells(j, 11).Value
    End If
    
    If ws.Cells(j, 11).Value < initial_pct_decrease Then
        initial_ticker_decrease = ws.Cells(j, 9).Value
        initial_pct_decrease = ws.Cells(j, 11).Value
    End If
    
    If ws.Cells(j, 12).Value > initial_volume Then
        initial_ticker_volume = ws.Cells(j, 9).Value
        initial_volume = ws.Cells(j, 12).Value
    End If
        
Next j

'Headers for greatest/least cells and values
ws.Cells(2, 14).Value = "Greatest % Increase"
ws.Cells(2, 15).Value = initial_ticker_increase
ws.Cells(2, 16).Value = FormatPercent(initial_pct_increase)
'Worksheets("Sheet1").Range("A1:E1").Columns.AutoFit



ws.Cells(3, 14).Value = "Greatest % Decrease"
ws.Cells(3, 15).Value = initial_ticker_decrease
ws.Cells(3, 16).Value = FormatPercent(initial_pct_decrease)



ws.Cells(4, 14).Value = "Greatest Total Volume"
ws.Cells(4, 14).Columns.AutoFit

ws.Cells(4, 15).Value = initial_ticker_volume
ws.Cells(4, 16).Value = initial_volume

ws.Cells(1, 15).Value = "Ticker"
ws.Cells(1, 16).Value = "Value"



'MsgBox("lastrow_of_newlist: " + str(lastrow_of_newlist))




Next ws








End Sub

