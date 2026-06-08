# Versões NPM oficiais (matriz de referência)

Valores obtidos do registry público npm. **Atualizar este ficheiro** sempre que subir versões nas apps ou quando quiseres sincronizar a documentação com o estado actual do ecossistema AG-UI.

## Registo actual

| Pacote | Versão | Data de consulta |
|--------|--------|------------------|
| `@ag-ui/core` | 0.0.50 | 03/04/2026 |
| `@ag-ui/client` | 0.0.50 | 03/04/2026 |
| `create-ag-ui-app` | 0.0.50 | 03/04/2026 |

## Como refrescar (Windows PowerShell)

Na raiz de qualquer pasta com Node/npm:

```powershell
npm view @ag-ui/core version
npm view @ag-ui/client version
npm view create-ag-ui-app version
```

Copiar os valores para a tabela acima e a data em **DD/MM/AAAA** (BRT).

## Nota

Versões `0.0.x` indicam evolução rápida do pacote; em projectos de produção convém fixar intervalos exactos em `package.json` e repetir o refresh acima antes de bumps maiores.
