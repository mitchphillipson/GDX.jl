using GamsStructure
using GDX

GU = load_universe_gdx("small_file.gdx")

print(GU)

print(GU[:X])