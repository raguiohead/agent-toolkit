<#
.SYNOPSIS
    Instala e sincroniza o Arsenal de IA (Skills, Subagentes e MCPs) nos agentes locais.

.DESCRIPTION
    Cria Directory Junctions (links NTFS) sem exigir privilegios de administrador
    para as pastas do Claude Code e Antigravity.

.PARAMETER Target
    Alvo da instalacao: 'All' (padrao), 'Claude' ou 'Antigravity'.

.PARAMETER DryRun
    Simula a execucao exibindo as acoes sem criar ou modificar arquivos/links.

.PARAMETER Force
    Sobrescreve junctions existentes caso apontem para caminhos desatualizados.

.EXAMPLE
    .\scripts\setup.ps1 -DryRun
    .\scripts\setup.ps1 -Target Claude
    .\scripts\setup.ps1
#>

[CmdletBinding()]
param(
    [ValidateSet('All', 'Claude', 'Antigravity')]
    [string]$Target = 'All',

    [switch]$DryRun,
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
$RepoRoot = (Resolve-Path "$PSScriptRoot\..").Path

Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "  Agent Toolkit - Setup e Sincronizacao Local           " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Repositorio: $RepoRoot" -ForegroundColor Gray
Write-Host "Alvo:        $Target" -ForegroundColor Gray
if ($DryRun) {
    Write-Host "MODO:        SIMULACAO (-DryRun ativo)" -ForegroundColor Yellow
}
Write-Host "--------------------------------------------------------" -ForegroundColor Gray

# Diretorios dos Agentes
$ClaudeSkillsDir      = "$HOME\.claude\skills"
$ClaudeAgentsDir      = "$HOME\.claude\agents"
$AntigravitySkillsDir = "$HOME\.gemini\config\skills"

# Contadores
$stats = @{
    SkillsCriadas    = 0
    SkillsJaExistem  = 0
    SkillsBackup     = 0
    AgentsCriados    = 0
    AgentsJaExistem  = 0
}

function Ensure-Directory([string]$Path) {
    if (-not (Test-Path $Path)) {
        if ($DryRun) {
            Write-Host "[DRY-RUN] Criaria pasta: $Path" -ForegroundColor DarkGray
        } else {
            New-Item -ItemType Directory -Path $Path -Force | Out-Null
        }
    }
}

function Create-SkillJunction([string]$SkillSourceDir, [string]$DestParentDir, [string]$AgentName) {
    $skillName = Split-Path $SkillSourceDir -Leaf
    $destPath = Join-Path $DestParentDir $skillName

    Ensure-Directory $DestParentDir

    if (Test-Path $destPath) {
        $item = Get-Item $destPath -Force
        # Verifica se ja e Junction
        if ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
            $currentTarget = $item.Target
            if ($currentTarget -eq $SkillSourceDir -or $currentTarget -contains $SkillSourceDir) {
                Write-Host "  [$AgentName] OK (Junction ativa): $skillName" -ForegroundColor DarkGray
                $script:stats.SkillsJaExistem++
                return
            } else {
                if ($Force -or $DryRun) {
                    Write-Host "  [$AgentName] RE-VINCULANDO: $skillName" -ForegroundColor Yellow
                    if (-not $DryRun) {
                        Remove-Item $destPath -Force
                        New-Item -ItemType Junction -Path $destPath -Target $SkillSourceDir | Out-Null
                    }
                    $script:stats.SkillsCriadas++
                    return
                }
            }
        } else {
            # E uma pasta fisica real: fazer backup seguro
            $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupPath = "$destPath.bak_$timestamp"
            Write-Host "  [$AgentName] BACKUP: Pasta fisica existente movida para $backupPath" -ForegroundColor Magenta
            if (-not $DryRun) {
                Move-Item -Path $destPath -Destination $backupPath -Force
                New-Item -ItemType Junction -Path $destPath -Target $SkillSourceDir | Out-Null
            }
            $script:stats.SkillsBackup++
            $script:stats.SkillsCriadas++
            return
        }
    }

    # Criar nova junction
    if ($DryRun) {
        Write-Host "  [$AgentName] [DRY-RUN] Criaria junction: $skillName" -ForegroundColor Cyan
    } else {
        New-Item -ItemType Junction -Path $destPath -Target $SkillSourceDir | Out-Null
        Write-Host "  [$AgentName] CRIADO: $skillName" -ForegroundColor Green
    }
    $script:stats.SkillsCriadas++
}

# 1. PROCESSAR SKILLS
Write-Host "`nSincronizando Skills..." -ForegroundColor White
$skillDirs = Get-ChildItem -Path "$RepoRoot\skills" -Recurse -Directory | Where-Object {
    Test-Path (Join-Path $_.FullName "SKILL.md")
}

foreach ($s in $skillDirs) {
    if ($Target -eq 'All' -or $Target -eq 'Claude') {
        Create-SkillJunction -SkillSourceDir $s.FullName -DestParentDir $ClaudeSkillsDir -AgentName "Claude"
    }
    if ($Target -eq 'All' -or $Target -eq 'Antigravity') {
        Create-SkillJunction -SkillSourceDir $s.FullName -DestParentDir $AntigravitySkillsDir -AgentName "Antigravity"
    }
}

# 2. PROCESSAR SUBAGENTES (CLAUDE CODE)
if ($Target -eq 'All' -or $Target -eq 'Claude') {
    Write-Host "`nSincronizando Subagentes no Claude Code..." -ForegroundColor White
    Ensure-Directory $ClaudeAgentsDir

    # Criar Junctions para as subpastas em agents/
    $agentCatDirs = Get-ChildItem -Path "$RepoRoot\agents" -Directory
    foreach ($cat in $agentCatDirs) {
        $destCatDir = Join-Path $ClaudeAgentsDir $cat.Name
        if (Test-Path $destCatDir) {
            $item = Get-Item $destCatDir -Force
            if (-not ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) {
                if (-not $DryRun) {
                    Remove-Item $destCatDir -Recurse -Force
                    New-Item -ItemType Junction -Path $destCatDir -Target $cat.FullName | Out-Null
                }
            }
        } else {
            if (-not $DryRun) {
                New-Item -ItemType Junction -Path $destCatDir -Target $cat.FullName | Out-Null
            }
        }
    }

    # Sincronizar arquivos .md diretamente na raiz de ~/.claude/agents/
    $agentFiles = Get-ChildItem -Path "$RepoRoot\agents" -Recurse -Filter "*.md"
    foreach ($a in $agentFiles) {
        $destAgentFile = Join-Path $ClaudeAgentsDir $a.Name
        $needsSync = $true

        if (Test-Path $destAgentFile) {
            if ((Get-FileHash $a.FullName).Hash -eq (Get-FileHash $destAgentFile).Hash) {
                $needsSync = $false
                $stats.AgentsJaExistem++
                Write-Host "  [Agent] OK: $($a.Name)" -ForegroundColor DarkGray
            }
        }

        if ($needsSync) {
            if ($DryRun) {
                Write-Host "  [Agent] [DRY-RUN] Copiaria: $($a.Name)" -ForegroundColor Cyan
            } else {
                Copy-Item -Path $a.FullName -Destination $destAgentFile -Force
                Write-Host "  [Agent] SINCRONIZADO: $($a.Name)" -ForegroundColor Green
            }
            $stats.AgentsCriados++
        }
    }
}

# RELATORIO FINAL
Write-Host "`n========================================================" -ForegroundColor Cyan
Write-Host "  Sincronizacao Concluida com Sucesso!                  " -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host "Skills Criadas / Atualizadas: $($stats.SkillsCriadas)" -ForegroundColor Green
Write-Host "Skills Ja Vinculadas:         $($stats.SkillsJaExistem)" -ForegroundColor Gray
Write-Host "Backups de Pastas Fisicas:    $($stats.SkillsBackup)" -ForegroundColor Magenta
Write-Host "Subagentes Sincronizados:     $($stats.AgentsCriados)" -ForegroundColor Green
Write-Host "Subagentes Ja Identicos:      $($stats.AgentsJaExistem)" -ForegroundColor Gray
Write-Host "========================================================`n" -ForegroundColor Cyan
