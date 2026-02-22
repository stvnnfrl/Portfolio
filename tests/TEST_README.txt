I feel like there is value in keeping the godot project "clean" of any external things like tests.
I propose that there be a distinct project that takes an EXPORTED hpp project and tests that.
This is possible by loading the pck file at runtime, but this would be quite a bit of hassle
to cross the boundary between two projects just to keep tests separate, but the idea is here.
