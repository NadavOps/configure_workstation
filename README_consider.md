Missing:
* Required bash 5 or package parsing fails (to solve run once then run brew install bash)
* code command for VScode does not populate by default
* vscode configuration:
```json
{
    "search.useIgnoreFiles": false,
    "remote.SSH.configFile": "/path_to/.ssh/config.vscode",
    "files.associations": {
        "**/.aws/config*": "ini",
        "**/.aws/config.d/*": "ini"
    }
}
```
* colima, builder, ecr adjust
    * docker buildx create --name mybuilder --bootstrap --use
    * colima stop && rm -rf ~/.colima && colima delete default (colima reset)
    * colima start --vm-type vz --mount-type virtiofs --cpu 4 --memory 4 --disk 60 (mac suggested)
    * colima start --vm-type qemu --mount-type sshfs --cpu 4 --memory 4 --disk 60 (default)

MAC additional software to consider:
* clipboard manager
    * clipy
    * maccy (not from app store)
* Screen management
    * rectangle (https://rectanglemac.app/) (suggested)
    * swish
* API client
    * insomnia
    * postman
    * rapidapi (free for personal use)


MAC soft configuration: (not programatic right now)
* keyboard:
    * key repeat rate (fastest)
    * delay until repeat (shortest)
    * enable "f" keys as standard function keys
        * keyboard -> key shortcuts -> function keys -> toggle the option "use f1, f2, etc. keys as standard keys"
    * disable smart quotes and dashes
        * keyboard -> input sources -> "use smart quotes and dashes"

Other:
* typing club to improve typing/ type racer
* uv package manager alternative to pip



<!-- jdk_v=17
rm "/tmp/openjdk.$jdk_v.images"
for page_num in {1..112}; do
    echo "page num $page_num"
    curl -s "https://registry.hub.docker.com/api/content/v1/repositories/public/library/openjdk/tags?page=$page_num&page_size=100" | jq -r ".results[].name" | grep -e "^$jdk_v" | grep -v "\-ea-" | grep -v "\-rc-" >> "/tmp/openjdk.$jdk_v.images"
done -->