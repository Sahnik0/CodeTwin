'use client'

import { useEffect, useState } from 'react'
import { QRCodeSVG } from 'qrcode.react'
import CopyButton from '@/components/CopyButton'

const PLACEHOLDER_ID = 'dt-a3f9b2c1d4e5'

type ConnectionStatus = 'waiting' | 'connected' | 'error'

export default function ConnectPage() {
  const [deviceId, setDeviceId] = useState<string>(PLACEHOLDER_ID)
  const [status, setStatus] = useState<ConnectionStatus>('waiting')
  const [appName, setAppName] = useState<string>('myapp')

  useEffect(() => {
    // Try to fetch real device info from the local daemon
    fetch('http://localhost:7483/connect', { signal: AbortSignal.timeout(3000) })
      .then((r) => r.json())
      .then((data) => {
        if (data.deviceId) setDeviceId(data.deviceId)
        if (data.appName) setAppName(data.appName)
        if (data.connected) setStatus('connected')
      })
      .catch(() => {
        // Daemon not running — show placeholder
        setStatus('waiting')
      })
  }, [])

  const pairingUrl = `CodeTwin://pair/${deviceId}`

  return (
    <div className="min-h-screen flex items-center justify-center px-6 pt-14 bg-background">
      <div className="w-full max-w-sm">
        {/* Card */}
        <div className="bg-surface border border-border-default rounded-lg p-8 flex flex-col items-center gap-6">
          {/* Wordmark */}
          <span className="font-mono text-sm text-text-primary">CodeTwin</span>

          {/* Heading */}
          <div className="text-center">
            <h1 className="text-xl font-medium text-text-primary mb-2">Pair your mobile device</h1>
            <p className="text-sm text-text-secondary">
              Scan this QR code with your phone or enter the device ID manually.
            </p>
          </div>

          {/* QR Code */}
          <div className="p-4 bg-white rounded-lg">
            <QRCodeSVG
              value={pairingUrl}
              size={160}
              bgColor="#ffffff"
              fgColor="#0a0a0a"
              level="M"
            />
          </div>

          {/* Device ID */}
          <div className="w-full">
            <p className="text-xs text-text-muted mb-2 text-center">Device ID</p>
            <div className="flex items-center gap-2 bg-surface-elevated border border-border-default rounded-lg px-3 py-2">
              <code className="font-mono text-sm text-text-primary flex-1 text-center">
                {deviceId}
              </code>
              <CopyButton text={deviceId} label="Copy device ID" />
            </div>
          </div>

          {/* Status */}
          <div className="flex items-center gap-2">
            {status === 'waiting' && (
              <>
                <span className="w-2 h-2 rounded-full bg-warning pulse-dot" />
                <span className="text-xs text-text-secondary">
                  Waiting for daemon connection...
                </span>
              </>
            )}
            {status === 'connected' && (
              <>
                <span className="w-2 h-2 rounded-full bg-success" />
                <span className="text-xs text-success">
                  Connected · {appName} · level 3
                </span>
              </>
            )}
            {status === 'error' && (
              <>
                <span className="w-2 h-2 rounded-full bg-danger" />
                <span className="text-xs text-danger">Could not reach daemon</span>
              </>
            )}
          </div>
        </div>

        {/* Hint */}
        <p className="mt-5 text-center text-xs text-text-muted">
          Run{' '}
          <code className="font-mono bg-surface-elevated border border-border-default rounded px-1.5 py-0.5">
            CodeTwin connect
          </code>{' '}
          in your terminal to start the daemon.
        </p>
      </div>
    </div>
  )
}
