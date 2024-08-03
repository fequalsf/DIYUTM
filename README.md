**DIYUTM - The open Source, 3D printed compression testing machine**

![DIYUTM-CAD](https://github.com/user-attachments/assets/54913d00-ef91-4537-8132-5be35a471db3)

The goal of DIYUTM is to make a low cost, 3d printable, universal testing machine. It uses inexpensive components and hardware. Most that you may find in a rep-rap 3d printer, or can find online easily.

It runs on an Arduino Uno with 2 Nema17 stepper motors. For measurement, it uses 4 50kg load cells (the kind you find in bathroom scales) and a HX711 load cell amplifier.

![61Tn-HJdFRL](https://github.com/user-attachments/assets/b1163109-8f4d-466d-b288-78f344e70587)

V1 design is intended to be printed with an FDM machine (preferably in PETG). The size of each part is meant to fit on a build plate of 200x200 (Creality Ender3).

![DIYUTM2](https://github.com/user-attachments/assets/ffe0cbb2-2ede-464f-a75a-1c7941e5bec5)

The interface is written in Processing and can be compiled into an executable.

![2024-05-04 12-17-04](https://github.com/user-attachments/assets/ee8e0747-0707-4fb1-a490-35e48f3eb646)



**DISCLAIMER:**

I am not, nor claim to be, an engineer. The idea was I would publish this open source and hopefully some engineers would work on the design. There are a lot of improvements to be made. But for now, it works for me and I haven't spent more time on it. Im hoping you will!

**TODO:**

1. While the load cells can read up to 200kg, the motors cannot provide that much torque. Currently my motors start to skip around 50kg. What needs to be designed is a better gear reduction. Another quick solution could be to buy motors with gear boxes that provide enough reduction.

2. The design was inteded to work in compression and tension. The idea was to drill holes in the load cells to attach with screws. But, the load cells are hardened steel and difficult to drill without a drill press or proper tools. Maybe it could be designed so that you dont need to drill any holes?

3. Design some attachments! The holes for inserts on the platform and gantry are intended for different attachments. If you want to do shear tests, or tensile tests, you can design the attachments for those.


