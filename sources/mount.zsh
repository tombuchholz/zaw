autoload -U read-from-minibuffer

function zaw-src-mount() {
    local desc="$(lsblk -afl)"
    #desc="$(echo $desc | cut -f 1 -d ' ')"
        
        : ${(A)cand_descriptions::=${(f)desc}}
        : ${(A)candidates::=${(f)desc}}
    actions=(zaw-src-mount-filesystem \
             zaw-src-mount-and-mkdir \
             zaw-src-mount-to-partition-name \
             zaw-src-unmount-clean \
             zaw-src-unmount)
    act_descriptions=("mount to..." \
                      "mount and mkdir..." \
                      "mount to partition name" \
                      "unmount + clean" \
                      "unmount")
    options=()
}

function _zaw-src-git-log-strip(){
    echo $1 | sed -e 's/^[*|/\\ ]* \([a-f0-9]*\) .*/\1/'
}

function zaw-src-mount-filesystem(){
    local hash_val=$(echo /dev/$(lsblk -afl | grep -i $1 | cut -f 1 -d " "))
    LBUFFER="sudo mount $hash_val "
    #zle accept-line
}

function zaw-src-mount-and-mkdir(){
    local partname=$(lsblk -afl | grep -i $1 | cut -f 1 -d " ")
    local partpath=$(echo /dev/$partname)

    local buf
    read-from-minibuffer "mountpoint: "
    #buf=$(${(Q@)${(z)REPLY}})
    buf=${(z)REPLY}

    mkdir $buf # Create directory
    LBUFFER="sudo mount $partpath $buf"
    zle accept-line

}

function zaw-src-mount-to-partition-name(){
    local partname=$(lsblk -afl | grep -i $1 | awk '{print $1}')
    local partpath=$(echo /dev/$partname)

    mkdir $partname # Create directory
    LBUFFER="sudo mount $partpath $partname"
    zle accept-line
}

function zaw-src-unmount(){
    local partname=$(lsblk -afl | grep -i $1 | awk '{print $1}')
    local partpath=$(echo /dev/$partname)
    sudo umount $partpath
    echo "done"
}

function zaw-src-unmount-clean(){
    local partname=$(lsblk -afl | grep -i $1 | awk '{print $1}')
    local partpath=$(echo /dev/$partname)
    local mountpoint=$(lsblk -afl | grep -i $1 | awk '{print $5}')

    sudo umount $partpath
    rmdir $mountpoint
    echo "done"
}

zaw-register-src -n mount zaw-src-mount
