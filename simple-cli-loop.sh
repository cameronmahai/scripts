while true; do
    read -p "Enter command (exit to quit): " cmd
    
    if [[ "$cmd" == "exit" ]]; then
        break
    elif [[ "$cmd" == "help" ]]; then
        echo "Available commands: help, exit, ..."
    elif [[ "$cmd" == "hello" ]]; then
        echo "Hello, World!"
    elif [[ "$cmd" == "create" ]]; then
	touch created-file-1.txt
    else
        eval "$cmd"
    fi
done
