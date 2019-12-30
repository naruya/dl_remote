import gym
env = gym.make("Humanoid-v2")
o = env.reset()
for _ in range(1000):
    env.render()
    a = env.action_space.sample()
    o, r, done, info = env.step(a)
    if done:
        o = env.reset()
env.close()