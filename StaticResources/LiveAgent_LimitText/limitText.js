function limitText(ref, maxChar){
    var val = ref.value;
    if ( val.length >= maxChar ){
        ref.value = val.substr(0, maxChar);       
    }
    return true;
}