# Copyright (c) 2025 Sukhdeep Singh
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# finflow/config/settings.py

from __future__ import annotations
import os
from dataclasses import dataclass

from dotenv import load_dotenv
load_dotenv()

@dataclass(frozen=True)
class Settings:
    # Database
    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "budgetuser")
    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "changeme")
    POSTGRES_HOST: str = os.getenv("POSTGRES_HOST", "localhost")
    POSTGRES_PORT: str = os.getenv("POSTGRES_PORT", "5432")
    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "budgetdb")

    @property
    def DATABASE_URL(self) -> str:
        database_url = os.getenv("DATABASE_URL")

        if database_url is not None:
            return database_url
        else:
            return (
                f"postgresql+psycopg2://{self.POSTGRES_USER}:"
                f"{self.POSTGRES_PASSWORD}@{self.POSTGRES_HOST}:"
                f"{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
            )
    currency: str = "€"


settings = Settings()
