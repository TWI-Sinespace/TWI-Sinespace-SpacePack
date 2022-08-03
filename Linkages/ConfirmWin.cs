using UnityEngine;

#if !SPACE_MAIN
[AddComponentMenu("")]
#endif
public class ConfirmWin : ConfirmWinBaseInternal
{
    private void Awake()
    {
        _self = this;
        gameObject.SetActive(false);
    }
}
