import bpy
import bmesh
import math

# ── 파라미터 ─────────────────────────────────────────────
IN_W, IN_D, IN_H = 80.0, 60.0, 130.0     # 내부 PCB 공간 (X, Y, Z) mm
WALL = 2.4                                 # 벽 두께
CORNER_R = 8.0                             # 몸체 모서리 라운드 반지름
BEVEL_SEG = 6

OLED_W, OLED_H = 27.3, 27.8                # SSD1306 0.96" 모듈 기준 (가정, 실측 권장)
OLED_Z = IN_H * 0.68                       # 바닥에서 OLED 중심 높이

SERVO_L, SERVO_W, SERVO_H = 32.5, 12.5, 30.0   # SG90 대략치 (가정, 실측 권장)
SERVO_HOLE_SPACING = 28.0
SERVO_HOLE_D = 2.2
EAR_Z = IN_H * 0.92                        # 귀 위치 높이

TOGGLE_BUSHING_D = 6.2                     # 미니 토글스위치 부싱 지름 (가정)
TOGGLE_ARC_DEG = 30.0                       # 꼬리 상하 스윙 각도
TAIL_Z = IN_H * 0.15                        # 꼬리 위치 높이 (뒷면 하단)

BOSS_D = 5.0                                # 코너 스크류 보스 외경 (M2 자탭)
BOSS_HOLE_D = 1.8
BOSS_INSET = 10.0

EXT_W = IN_W + 2 * WALL
EXT_D = IN_D + 2 * WALL
EXT_H = IN_H + 2 * WALL


def clear_scene():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)


def add_box(name, w, d, h, loc=(0, 0, 0)):
    bpy.ops.mesh.primitive_cube_add(size=1, location=loc)
    obj = bpy.context.active_object
    obj.name = name
    obj.scale = (w, d, h)
    bpy.ops.object.transform_apply(scale=True)
    return obj


def add_cylinder(name, r, h, loc=(0, 0, 0), rot=(0, 0, 0)):
    bpy.ops.mesh.primitive_cylinder_add(radius=r, depth=h, location=loc, rotation=rot)
    obj = bpy.context.active_object
    obj.name = name
    return obj


def bevel_edges(obj, width, segments):
    mod = obj.modifiers.new("Bevel", 'BEVEL')
    mod.width = width
    mod.segments = segments
    mod.limit_method = 'ANGLE'
    bpy.context.view_layer.objects.active = obj
    bpy.ops.object.modifier_apply(modifier=mod.name)


def boolean(target, cutter, op='DIFFERENCE'):
    mod = target.modifiers.new("Bool", 'BOOLEAN')
    mod.object = cutter
    mod.operation = op
    bpy.context.view_layer.objects.active = target
    bpy.ops.object.modifier_apply(modifier=mod.name)
    bpy.data.objects.remove(cutter, do_unlink=True)


# ── 본체 쉘 ──────────────────────────────────────────────
def build_body_shell():
    outer = add_box("Body_Outer", EXT_W, EXT_D, EXT_H)
    bevel_edges(outer, CORNER_R, BEVEL_SEG)

    inner = add_box("Body_Inner", IN_W, IN_D, IN_H)
    boolean(outer, inner, 'DIFFERENCE')

    # OLED 창 (앞면, Y-)
    oled_cut = add_box("OLED_Cut", OLED_W, WALL * 4, OLED_H,
                        loc=(0, -EXT_D / 2, -EXT_H / 2 + OLED_Z))
    boolean(outer, oled_cut, 'DIFFERENCE')

    # 좌/우 귀 서보 포켓 (상단, X축 좌우면)
    for side in (-1, 1):
        pocket = add_box("Servo_Pocket", SERVO_H, SERVO_L, SERVO_W,
                          loc=(side * (EXT_W / 2 - SERVO_H / 2 + 1),
                               0, -EXT_H / 2 + EAR_Z))
        boolean(outer, pocket, 'DIFFERENCE')
        # 서보 축 관통 구멍
        shaft_hole = add_cylinder("Servo_Shaft_Hole", 3.0, WALL * 6,
                                   loc=(side * EXT_W / 2, 0, -EXT_H / 2 + EAR_Z),
                                   rot=(0, math.radians(90), 0))
        boolean(outer, shaft_hole, 'DIFFERENCE')
        # 서보 마운팅 스크류 홀 2개
        for hy in (-SERVO_HOLE_SPACING / 2, SERVO_HOLE_SPACING / 2):
            hole = add_cylinder("Servo_Mount_Hole", SERVO_HOLE_D / 2, WALL * 6,
                                 loc=(side * (EXT_W / 2 - SERVO_H), hy,
                                      -EXT_H / 2 + EAR_Z),
                                 rot=(0, math.radians(90), 0))
            boolean(outer, hole, 'DIFFERENCE')

    # 꼬리 토글스위치 부싱 홀 + 스윙 슬롯 (뒷면, Y+)
    bushing_hole = add_cylinder("Toggle_Hole", TOGGLE_BUSHING_D / 2, WALL * 6,
                                 loc=(0, EXT_D / 2, -EXT_H / 2 + TAIL_Z),
                                 rot=(math.radians(90), 0, 0))
    boolean(outer, bushing_hole, 'DIFFERENCE')

    arc_slot = add_box("Tail_Arc_Slot", 10.0, WALL * 4,
                        2 * (IN_H * 0.06) * math.tan(math.radians(TOGGLE_ARC_DEG)),
                        loc=(0, EXT_D / 2, -EXT_H / 2 + TAIL_Z))
    boolean(outer, arc_slot, 'DIFFERENCE')

    # 코너 스크류 보스 4개 (내부 바닥 모서리)
    for sx in (-1, 1):
        for sy in (-1, 1):
            bx = sx * (IN_W / 2 - BOSS_INSET)
            by = sy * (IN_D / 2 - BOSS_INSET)
            boss = add_cylinder("Boss", BOSS_D / 2, IN_H - WALL,
                                 loc=(bx, by, -EXT_H / 2 + WALL + (IN_H - WALL) / 2))
            boolean(outer, boss, 'UNION')
            hole = add_cylinder("Boss_Hole", BOSS_HOLE_D / 2, IN_H,
                                 loc=(bx, by, -EXT_H / 2 + WALL + IN_H / 2))
            boolean(outer, hole, 'DIFFERENCE')

    outer.name = "Body_Shell"
    return outer


def split_front_back(body):
    front = body.copy()
    front.data = body.data.copy()
    bpy.context.collection.objects.link(front)
    front.name = "Body_Front"

    back = body
    back.name = "Body_Back"

    cutter_f = add_box("CutF", EXT_W * 2, EXT_D, EXT_H * 2, loc=(0, EXT_D / 4, 0))
    boolean(front, cutter_f, 'DIFFERENCE')

    cutter_b = add_box("CutB", EXT_W * 2, EXT_D, EXT_H * 2, loc=(0, -EXT_D / 4, 0))
    boolean(back, cutter_b, 'DIFFERENCE')

    return front, back


# ── 귀 ───────────────────────────────────────────────────
def build_ear(side=1):
    ear = add_box(f"Ear_{'R' if side > 0 else 'L'}", 18, 8, 24,
                  loc=(side * 40, 0, 0))
    bevel_edges(ear, 6.0, 6)

    socket = add_cylinder("Ear_Socket", 3.2, 6.0,
                           loc=(side * 40, 0, -8), rot=(0, math.radians(90), 0))
    boolean(ear, socket, 'DIFFERENCE')
    return ear


# ── 꼬리 ─────────────────────────────────────────────────
def build_tail():
    tail = add_box("Tail", 14, 40, 14, loc=(0, 20, 0))
    bevel_edges(tail, 5.0, 6)

    socket = add_cylinder("Tail_Socket", TOGGLE_BUSHING_D / 2 + 0.3, 10.0,
                           loc=(0, -18, 0), rot=(math.radians(90), 0, 0))
    boolean(tail, socket, 'DIFFERENCE')
    return tail


def main():
    clear_scene()
    body = build_body_shell()
    front, back = split_front_back(body)
    front.location.x = -EXT_W * 1.5
    back.location.x = EXT_W * 1.5
    build_ear(-1)
    build_ear(1)
    build_tail()


main()
