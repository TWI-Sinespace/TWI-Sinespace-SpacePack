using UnityEngine;
#if UNITY_2018_1_OR_NEWER
using ParticleEmitter = SineSpace.Upgrades.ParticleEmitter;
#endif

[RequireComponent(typeof (CharacterController))]
public class SurfingVehicle : BaseVehicleBehaviourBaseInternal
{
    private ParticleEmitter[] emitters;
    private float[] minParticles;
    private float[] maxParticles;
    private float[] maxSize;
    private float[] minSize;
    public AnimationClip SurfingAnimation;

    private bool _initialised;

    public void Start()
    {
        if (_initialised)
            return;
        _initialised = true;

        OriginalSpeed = Speed;

        Debug.Log("Starting surfboard");
        Initialise();

        GetComponent<CharacterController>().enabled = false;

        // Setup tweaks to the water particle systems we have
        emitters = GetComponentsInChildren<ParticleEmitter>();
        minParticles = new float[emitters.Length];
        maxParticles = new float[emitters.Length];
        minSize = new float[emitters.Length];
        maxSize = new float[emitters.Length];

        for (int i = 0; i < emitters.Length; i++)
        {
            ParticleEmitter emitter = emitters[i];

            minParticles[i] = emitter.minEmission;
            maxParticles[i] = emitter.maxEmission;
            minSize[i] = emitter.minSize;
            maxSize[i] = emitter.maxSize;
        }
//#if !SPACE_DLL        
        //if (IsSpawnByUser && !WorldManager.PlayerAvatar.Locked)
        //    ActivateVehicle();
//#endif        
    }

    public float Speed = 3.0F;
    internal float OriginalSpeed;
    public float RotateSpeed = 3.0F;

    protected new void Update()
    {
        CharacterController controller = GetComponent<CharacterController>();
        transform.Rotate(0, SWInput.Horizontal*RotateSpeed*(60)*Time.deltaTime, 0);
        Vector3 forward = transform.TransformDirection(Vector3.forward);
        float curSpeed = Speed * Mathf.Clamp01(Mathf.Clamp01(SWInput.Vertical) + 0.75f);
        controller.SimpleMove(forward * curSpeed);
        base.Update();
    }

    protected void FixedUpdate()
    {
        SyncStateWithWorld();

        for (int i = 0; i < emitters.Length; i++)
        {
            ParticleEmitter emitter = emitters[i];

            if (emitter.enabled && !Active)
                emitter.ClearParticles();

            emitter.enabled = Active;

            float magnitude = 1f;

            var cc = GetComponent<CharacterController>();

            if (cc.velocity.magnitude < 1f)
                magnitude = 0f;
            else
                magnitude = cc.velocity.magnitude;

            magnitude /= 5f;

            emitter.minEmission = minParticles[i] * magnitude;
            emitter.maxEmission = minParticles[i] * magnitude;
            emitter.minSize = minSize[i] * Mathf.Clamp01(magnitude);
            emitter.maxSize = maxSize[i] * Mathf.Clamp01(magnitude);
        }
    }

    protected override void ActivateVehicle()
    {
        if (!_initialised)
            Start();

        GetComponent<CharacterController>().enabled = true;

        base.ActivateVehicle();
        
        //SetCameraRotateSpeed(1080);

        PlayerAvatar.Animator.PlayAnimation(SurfingAnimation);

        //PlayerCharacter.GetComponentInChildren<RPG_Animation>().AddAnimationAndPlay("surfing", SurfingAnimation, true);
    }

    protected override void DeactivateVehicle()
    {
        GetComponent<CharacterController>().enabled = false;
        PlayerAvatar.Animator.ForceIdle();
        base.DeactivateVehicle();
    }
}