Write-Host "Atualizando branch local com o remoto..."
git pull origin gh-pages

Write-Host "Adicionando arquivos modificados..."
git add .

$msg = Read-Host "Digite a mensagem do commit"

git commit -m "$msg"

Write-Host "Enviando para o GitHub..."
git push origin gh-pages

Write-Host "Pronto! Push realizado com sucesso."
