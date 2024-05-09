from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from starlette.middleware.cors import CORSMiddleware


from api.hb.hb_api import hb
from api.hc.hc_api import hc
from api.hs.hs_api import hs
from api.yj.yj_api import yj


app = FastAPI()
app.mount("/static", StaticFiles(directory="static"), name="static")
app.include_router(hc, prefix="/hc")
app.include_router(hb, prefix="/hb")
app.include_router(hs, prefix="/hs")
app.include_router(yj, prefix="/yj")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
