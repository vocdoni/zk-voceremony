
ask_to_user() {
    local asnwer=""
    if [ -n "$2" ]; then
        read -p "$1 " answer
        if [ -n "$answer" ]; then
            echo "$answer"
            return
        else 
            echo "$2"
            return
        fi
    fi

    while true; do
        read -p "$1 " answer
        # Check if the alias is not empty
        if [ -n "$answer" ]; then
            break
        fi
    done
    echo "$answer"
}


echo "\nThis script will create a ceremony.env file with the following content:
    * TARGET_CIRCUIT: the path to the circom circuit file
    * INPUT_PTAU: the path to the input ptau file
    * CEREMONY_BRANCH: the name of the ceremony (and its branch)
    * CONTRIBUTIONS_PATH: the path to the folder to store the contributions files
    * OUTPUT_PATH: the path to the folder to store the resulting files\n"

input_folder=`ask_to_user "Please enter the path to the folder to store the inputs files (by default './inputs'): " "./inputs"`
mkdir -p $input_folder

target_circuit=`ask_to_user "Please enter the path to the circom circuit file: "`
if [ ! -f "$target_circuit" ]; then
    echo "The file '$target_circuit' does not exists"
    exit 1
fi

input_ptau=$(ask_to_user "Please enter the path to the input ptau file: ")
if [ ! -f "$input_ptau" ]; then
    echo "The file '$input_ptau' does not exists"
    exit 1
fi

ceremony_branch=$(ask_to_user "Please enter the name of the ceremony (and its branch): ")
contributions_path=`ask_to_user "Please enter the path to the folder to store the contributions files (by default './contributions'): " "./contributions"`
output_path=`ask_to_user "Please enter the path to the folder to store the resulting files (by default './results'): " "./results"`

circuit_file=$(basename -- "$target_circuit")
cp $target_circuit $input_folder/$circuit_file
ptau_file=$(basename -- "$input_ptau")
cp $input_ptau $input_folder/$ptau_file

echo "TARGET_CIRCUIT=$input_folder/$circuit_file
INPUT_PTAU=$input_folder/$ptau_file
CEREMONY_BRANCH=$ceremony_branch
CONTRIBUTIONS_PATH=$contributions_path
OUTPUT_PATH=$output_path" > ceremony.env

git checkout -b $ceremony_branch
git add -f ceremony.env $input_folder/$circuit_file $input_folder/$ptau_file
git commit -m "Initialize ceremony"
git push origin $ceremony_branch
