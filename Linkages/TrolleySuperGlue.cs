using System.Collections;
using UnityEngine;

public class TrolleySuperGlue : SynchronisedDestructableBaseInternal
{
    public float GlueTime = 5f;
    public float GlueDensity = 5f;
    public ParticleSystem Particles;

    /*
                Banana skin: Make the cart lose control
                N2O加速：玩家的购物车在短时间内获得强力的加速性能。
                N2O speeding up: Make the cart speeding up in short time.
                西瓜弹：玩家可投掷出一个西瓜，在目标区域造成范围伤害。
                Water melon: the player can shoot a water melon which cause the damage in certain area.
                强力胶：压到的玩家速度变为0并固定在原地，持续3秒钟。
                Power gluewater: Make the cart stay for three seconds.

                跟踪炸弹：发射一枚炸弹，5秒内持续跟踪前方距离最近的敌人，一旦击中则会产生大量伤害。
                Tracing rocket: Shoot a rocket, tracing the enemy in 5 seconds, once shoot will hurt a lot.
                电击弹：使被击中的玩家购物车丧失加速能力，持续5秒。
                Electric bomb: make the cart cannot speed up for 5 seconds.
             */

    public void Start()
    {
        StartCoroutine(PlayEffectStart());
    }

    public IEnumerator PlayEffectStart()
    {
        if (Particles != null)
            Particles.Play();
        yield return new WaitForSeconds(2.5f);
        if (Particles != null)
            Particles.Pause();
    }

    public void OnTriggerEnter(Collider c)
    {
        if (c != null && c.attachedRigidbody != null && c.gameObject != null)
        {
            float baseDensity = c.attachedRigidbody.mass;
            float glueDensity = baseDensity*GlueDensity;

            c.attachedRigidbody.velocity = Vector3.zero;

            //WheelCollider[] colliders = c.gameObject.GetComponentsInChildren<WheelCollider>();

            LeanTween.value(c.gameObject, delegate(float f)
            {
                c.attachedRigidbody.velocity /= 2f; // Keep velocity low

                f = Mathf.Lerp(glueDensity, 1f, Mathf.InverseLerp(0.7f, 1f, f));

                c.attachedRigidbody.mass = f;

                //c.rigidbody.SetDensity(f);

            }, 0f, 1f, GlueTime);
        }

        Explode();
    }

    public void Explode()
    {
        if (Particles != null)
        {
            Particles.Play();
            Particles.gameObject.transform.parent = null;
            Particles.gameObject.AddComponent<DestroyAfterSeconds>().Seconds = 3f;
        }

        Destroy(gameObject);
    }

    public override void OnDestroy()
    {
        base.OnDestroy();
    }
}
