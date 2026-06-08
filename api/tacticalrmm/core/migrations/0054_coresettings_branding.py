from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ("core", "0053_coresettings_terminal_mode"),
    ]

    operations = [
        migrations.AddField(
            model_name="coresettings",
            name="brand_name",
            field=models.CharField(default="BDO RMM", max_length=255),
        ),
        migrations.AddField(
            model_name="coresettings",
            name="brand_logo",
            field=models.ImageField(blank=True, null=True, upload_to="branding/"),
        ),
        migrations.AddField(
            model_name="coresettings",
            name="brand_favicon",
            field=models.ImageField(blank=True, null=True, upload_to="branding/"),
        ),
        migrations.AddField(
            model_name="coresettings",
            name="brand_primary_color",
            field=models.CharField(default="#1976D2", max_length=7),
        ),
        migrations.AddField(
            model_name="coresettings",
            name="brand_secondary_color",
            field=models.CharField(default="#26A69A", max_length=7),
        ),
        migrations.AddField(
            model_name="coresettings",
            name="brand_accent_color",
            field=models.CharField(default="#9C27B0", max_length=7),
        ),
        migrations.AddField(
            model_name="coresettings",
            name="brand_header_color",
            field=models.CharField(default="#212121", max_length=50),
        ),
        migrations.AddField(
            model_name="coresettings",
            name="brand_login_bg_start",
            field=models.CharField(default="#14141D", max_length=7),
        ),
        migrations.AddField(
            model_name="coresettings",
            name="brand_login_bg_mid",
            field=models.CharField(default="#262A38", max_length=7),
        ),
        migrations.AddField(
            model_name="coresettings",
            name="brand_login_bg_end",
            field=models.CharField(default="#0F1214", max_length=7),
        ),
    ]
