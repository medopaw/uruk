#!/bin/sh

# 安装 ollama
install_with_brew ollama

# 检查 ollama 服务是否已经在运行
if brew services list | grep ollama | grep -q started; then
    echo "Ollama service is already running."
else
    echo "Starting ollama service..."
    brew services start ollama
    echo "Ollama service started successfully."
fi

echo "Ollama installed and service is running."
echo "You can now use 'ollama' commands to interact with the service."
echo ""
echo "To stop the service: brew services stop ollama"
echo "To restart the service: brew services restart ollama"